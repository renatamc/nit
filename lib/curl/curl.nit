# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2013 Matthieu Lucas <lucasmatthieu@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Network functionnalities based on Curl_c module.
module curl

import native_curl

# Top level of Curl
class Curl

	protected var native = new NativeCurl.easy_init

	# Check for correct initialization
	fun is_ok: Bool do return self.native.is_init

	# Release Curl instance
	fun destroy do self.native.easy_clean
end

# CURL Request
class CurlRequest

	private var curl: Curl

	# Shall this request be verbose?
	var verbose: Bool = false is writable

	# Launch request method
	fun execute: CurlResponse is abstract

	# Intern perform method, lowest level of request launching
	private fun perform: nullable CurlResponseFailed
	do
		if not self.curl.is_ok then return answer_failure(0, "Curl instance is not correctly initialized")

		var err

		err = self.curl.native.easy_setopt(new CURLOption.verbose, self.verbose)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		err = self.curl.native.easy_perform
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		return null
	end

	# Intern method with return a failed answer with given code and message
	private fun answer_failure(error_code: Int, error_msg: String): CurlResponseFailed
	do
		return new CurlResponseFailed(error_code, error_msg)
	end
end

# CURL HTTP Request
class CurlHTTPRequest
	super CurlRequest
	super NativeCurlCallbacks

	var url: String
	var datas: nullable HeaderMap = null is writable
	var headers: nullable HeaderMap = null is writable
	var delegate: nullable CurlCallbacks = null is writable

	# Set the user agent for all following HTTP requests
	fun user_agent=(name: String)
	do
		curl.native.easy_setopt(new CURLOption.user_agent, name)
	end

	# Execute HTTP request with settings configured through attribute
	redef fun execute
	do
		if not self.curl.is_ok then return answer_failure(0, "Curl instance is not correctly initialized")

		var success_response = new CurlResponseSuccess
		var callback_receiver: CurlCallbacks = success_response
		if self.delegate != null then callback_receiver = self.delegate.as(not null)

		var err

		err = self.curl.native.easy_setopt(new CURLOption.follow_location, 1)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		err = self.curl.native.easy_setopt(new CURLOption.url, url)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		# Callbacks
		err = self.curl.native.register_callback_header(callback_receiver)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		err = self.curl.native.register_callback_body(callback_receiver)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		# HTTP Header
		var headers = self.headers
		if headers != null then
			var headers_joined = headers.join_pairs(": ")
			err = self.curl.native.easy_setopt(new CURLOption.httpheader, headers_joined.to_curlslist)
			if not err.is_ok then return answer_failure(err.to_i, err.to_s)
		end

		# Datas
		var datas = self.datas
		if datas != null then
			var postdatas = datas.to_url_encoded(self.curl)
			err = self.curl.native.easy_setopt(new CURLOption.postfields, postdatas)
			if not err.is_ok then return answer_failure(err.to_i, err.to_s)
		end

		var err_resp = perform
		if err_resp != null then return err_resp

		var st_code = self.curl.native.easy_getinfo_long(new CURLInfoLong.response_code)
		if not st_code == null then success_response.status_code = st_code.response

		return success_response
	end

	# Download to file given resource
	fun download_to_file(output_file_name: nullable String): CurlResponse
	do
		var success_response = new CurlFileResponseSuccess

		var callback_receiver: CurlCallbacks = success_response
		if self.delegate != null then callback_receiver = self.delegate.as(not null)

		var err

		err = self.curl.native.easy_setopt(new CURLOption.follow_location, 1)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		err = self.curl.native.easy_setopt(new CURLOption.url, url)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		err = self.curl.native.register_callback_header(callback_receiver)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		err = self.curl.native.register_callback_stream(callback_receiver)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		var opt_name
		if not output_file_name == null then
			opt_name = output_file_name
		else if not self.url.substring(self.url.length-1, self.url.length) == "/" then
			opt_name = self.url.basename("")
		else
			return answer_failure(0, "Unable to extract file name, please specify one")
		end

		success_response.file = new FileWriter.open(opt_name)
		if not success_response.file.is_writable then
			return answer_failure(0, "Unable to create associated file")
		end

		var err_resp = perform
		if err_resp != null then return err_resp

		var st_code = self.curl.native.easy_getinfo_long(new CURLInfoLong.response_code)
		if not st_code == null then success_response.status_code = st_code.response

		var speed = self.curl.native.easy_getinfo_double(new CURLInfoDouble.speed_download)
		if not speed == null then success_response.speed_download = speed.response

		var size = self.curl.native.easy_getinfo_double(new CURLInfoDouble.size_download)
		if not size == null then success_response.size_download = size.response

		var time = self.curl.native.easy_getinfo_double(new CURLInfoDouble.total_time)
		if not time == null then success_response.total_time = time.response

		success_response.file.close

		return success_response
	end
end

# CURL Mail Request
class CurlMailRequest
	super CurlRequest
	super NativeCurlCallbacks

	var headers: nullable HeaderMap = null is writable
	var headers_body: nullable HeaderMap = null is writable
	var from: nullable String = null is writable
	var to: nullable Array[String] = null is writable
	var cc: nullable Array[String] = null is writable
	var bcc: nullable Array[String] = null is writable
	var subject: nullable String = "" is writable
	var body: nullable String = "" is writable
	private var supported_outgoing_protocol: Array[String] = ["smtp", "smtps"]

	# Helper method to add pair values to mail content while building it (ex: "To:", "address@mail.com")
	private fun add_pair_to_content(str: String, att: String, val: nullable String):String
	do
		if val != null then return "{str}{att}{val}\n"
		return "{str}{att}\n"
	end

	# Helper method to add entire list of pairs to mail content
	private fun add_pairs_to_content(content: String, pairs: HeaderMap):String
	do
		for h_key, h_val in pairs do content = add_pair_to_content(content, h_key, h_val)
		return content
	end

	# Check for host and protocol availability
	private fun is_supported_outgoing_protocol(host: String):CURLCode
	do
		var host_reach = host.split_with("://")
		if host_reach.length > 1 and supported_outgoing_protocol.has(host_reach[0]) then return once new CURLCode.ok
		return once new CURLCode.unsupported_protocol
	end

	# Configure server host and user credentials if needed.
	fun set_outgoing_server(host: String, user: nullable String, pwd: nullable String): nullable CurlResponseFailed
	do
		# Check Curl initialisation
		if not self.curl.is_ok then return answer_failure(0, "Curl instance is not correctly initialized")

		var err

		# Host & Protocol
		err = is_supported_outgoing_protocol(host)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)
		err = self.curl.native.easy_setopt(new CURLOption.url, host)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		# Credentials
		if not user == null and not pwd == null then
			err = self.curl.native.easy_setopt(new CURLOption.username, user)
			if not err.is_ok then return answer_failure(err.to_i, err.to_s)
			err = self.curl.native.easy_setopt(new CURLOption.password, pwd)
			if not err.is_ok then return answer_failure(err.to_i, err.to_s)
		end

		return null
	end

	# Execute Mail request with settings configured through attribute
	redef fun execute
	do
		if not self.curl.is_ok then return answer_failure(0, "Curl instance is not correctly initialized")

		var success_response = new CurlMailResponseSuccess
		var content = ""
		# Headers
		if self.headers != null then
			content = add_pairs_to_content(content, self.headers.as(not null))
		end

		# Recipients
		var g_rec = new Array[String]
		if self.to != null and self.to.length > 0 then
			content = add_pair_to_content(content, "To:", self.to.join(","))
			g_rec.append(self.to.as(not null))
		end
		if self.cc != null and self.cc.length > 0 then
			content = add_pair_to_content(content, "Cc:", self.cc.join(","))
			g_rec.append(self.cc.as(not null))
		end
		if self.bcc != null and self.bcc.length > 0 then g_rec.append(self.bcc.as(not null))

		if g_rec.length < 1 then return answer_failure(0, "The mail recipients can not be empty")

		var err

		err = self.curl.native.easy_setopt(new CURLOption.follow_location, 1)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		err = self.curl.native.easy_setopt(new CURLOption.mail_rcpt, g_rec.to_curlslist)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		# From
		if not self.from == null then
			content = add_pair_to_content(content, "From:", self.from)
			err = self.curl.native.easy_setopt(new CURLOption.mail_from, self.from.as(not null))
			if not err.is_ok then return answer_failure(err.to_i, err.to_s)
		end

		# Subject
		var subject = self.subject
		if subject == null then subject = ""
		content = add_pair_to_content(content, "Subject:", subject)

		# Headers body
		if self.headers_body != null then
			content = add_pairs_to_content(content, self.headers_body.as(not null))
		end

		# Body
		var body = self.body
		if body == null then body = ""

		content += "\n"
		content = add_pair_to_content(content, "", body)
		content += "\n"

		err = self.curl.native.register_callback_read(self)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		err = self.curl.native.register_read_datas_callback(self, content)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		var err_resp = perform
		if err_resp != null then return err_resp

		return success_response
	end
end

# Callbacks Interface, allow you to manage in your way the different streams
interface CurlCallbacks
	super NativeCurlCallbacks
end

# Abstract Curl request response
abstract class CurlResponse
end

# Failed Response Class returned when errors during configuration are raised
class CurlResponseFailed
	super CurlResponse

	var error_code: Int
	var error_msg: String
end

# Success Abstract Response Success Class
abstract class CurlResponseSuccessIntern
	super CurlCallbacks
	super CurlResponse

	var headers = new HashMap[String, String]

	# Receive headers from request due to headers callback registering
	redef fun header_callback(line)
	do
		var splitted = line.split_with(':')
		if splitted.length > 1 then
			var key = splitted.shift
			self.headers[key] = splitted.to_s
		end
	end
end

# Success Response Class of a basic response
class CurlResponseSuccess
	super CurlResponseSuccessIntern

	var body_str = ""
	var status_code = 0

	# Receive body from request due to body callback registering
	redef fun body_callback(line) do
		self.body_str = "{self.body_str}{line}"
	end
end

# Success Response Class of mail request
class CurlMailResponseSuccess
	super CurlResponseSuccessIntern
end

# Success Response Class of a downloaded File
class CurlFileResponseSuccess
	super CurlResponseSuccessIntern

	var status_code = 0
	var speed_download = 0
	var size_download = 0
	var total_time = 0
	private var file: nullable FileWriter = null

	# Receive bytes stream from request due to stream callback registering
	redef fun stream_callback(buffer)
	do
		file.write buffer
	end
end

# Pseudo map associating `String` to `String` for HTTP exchanges
#
# This structure differs from `Map` as each key can have multiple associations
# and the order of insertion is important to some services.
class HeaderMap
	private var array = new Array[Couple[String, String]]

	# Add a `value` associated to `key`
	fun []=(key, value: String)
	do
		array.add new Couple[String, String](key, value)
	end

	# Get a list of the keys associated to `key`
	fun [](k: String): Array[String]
	do
		var res = new Array[String]
		for c in array do if c.first == k then res.add c.second
		return res
	end

	# Iterate over all the associations in `self`
	fun iterator: MapIterator[String, String] do return new HeaderMapIterator(self)

	# Get `self` as a single string for HTTP POST
	#
	# Require: `curl.is_ok`
	fun to_url_encoded(curl: Curl): String
	do
		assert curl.is_ok

		var lines = new Array[String]
		for k, v in self do
			if k.length == 0 then continue

			k = curl.native.escape(k)
			v = curl.native.escape(v)
			lines.add "{k}={v}"
		end
		return lines.join("&")
	end

	# Concatenate couple of 'key value' separated by 'sep' in Array
	fun join_pairs(sep: String): Array[String]
	do
		var col = new Array[String]
		for k, v in self do col.add("{k}{sep}{v}")
		return col
	end

	# Number of values in `self`
	fun length: Int do return array.length

	# Is this map empty?
	fun is_empty: Bool do return array.is_empty
end

private class HeaderMapIterator
	super MapIterator[String, String]

	var map: HeaderMap
	var iterator: Iterator[Couple[String, String]] = map.array.iterator is lazy

	redef fun is_ok do return self.iterator.is_ok
	redef fun next do self.iterator.next
	redef fun item do return self.iterator.item.second
	redef fun key do return self.iterator.item.first
end
