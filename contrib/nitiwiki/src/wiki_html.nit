# This file is part of NIT ( http://www.nitlanguage.org ).
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

# HTML wiki rendering
module wiki_html

import wiki_links
import markdown::decorators

redef class Nitiwiki

	# Render HTML output looking for changes in the markdown sources.
	redef fun render do
		super
		if not root_section.is_dirty and not force_render then return
		var out_dir = expand_path(config.root_dir, config.out_dir)
		out_dir.mkdir
		copy_assets
		root_section.add_child make_sitemap
		root_section.render
	end

	# Copy the asset directory to the (public) output directory.
	private fun copy_assets do
		var src = expand_path(config.root_dir, config.assets_dir)
		var out = expand_path(config.root_dir, config.out_dir)
		if need_render(src, expand_path(out, config.assets_dir)) then
			if src.file_exists then sys.system "cp -R {src} {out}"
		end
	end

	# Build the wiki sitemap page.
	private fun make_sitemap: WikiSitemap do
		var sitemap = new WikiSitemap(self, "sitemap")
		sitemap.is_dirty = true
		return sitemap
	end

	# Markdown processor used for inline element such as titles in TOC.
	private var inline_processor: MarkdownProcessor is lazy do
		var proc = new MarkdownProcessor
		proc.emitter.decorator = new InlineDecorator
		return proc
	end

	# Inline markdown (remove h1, p, ... elements).
	private fun inline_md(md: Writable): Writable do
		return inline_processor.process(md.write_to_string)
	end
end

redef class WikiEntry
	# Get a `<a>` template link to `self`
	fun tpl_link: Writable do
		return "<a href=\"{url}\">{title}</a>"
	end
end

redef class WikiSection

	# Output directory (where to ouput the HTML pages for this section).
	redef fun out_path: String do
		if parent == null then
			return wiki.config.out_dir
		else
			return wiki.expand_path(parent.out_path, name)
		end
	end

	redef fun render do
		if not is_dirty and not wiki.force_render then return
		if is_new then
			out_full_path.mkdir
		else
			sys.system "touch {out_full_path}"
		end
		if has_source then
			wiki.message("Render section {out_path}", 1)
			copy_files
		end
		var index = self.index
		if index isa WikiSectionIndex then
			wiki.message("Render auto-index for section {out_path}", 1)
			index.is_dirty = true
			add_child index
		end
		super
	end

	# Copy attached files from `src_path` to `out_path`.
	private fun copy_files do
		assert has_source
		var dir = src_full_path.to_s
		for name in dir.files do
			if name == wiki.config_filename then continue
			if name.has_suffix(".md") then continue
			if has_child(name) then continue
			var src = wiki.expand_path(dir, name)
			var out = wiki.expand_path(out_full_path, name)
			if not wiki.need_render(src, out) then continue
			sys.system "cp -R {src} {out_full_path}"
		end
	end

	redef fun tpl_link do return index.tpl_link

	# Render the section hierarchy as a html tree.
	#
	# `limit` is used to specify the max-depth of the tree.
	#
	# The generated tree will be something like this:
	#
	# ~~~html
	# <ul>
	#  <li>section 1</li>
	#  <li>section 2
	#   <ul>
	#    <li>section 2.1</li>
	#    <li>section 2.2</li>
	#   </ul>
	#  </li>
	# </ul>
	# ~~~
	fun tpl_tree(limit: Int): Template do
		return tpl_tree_intern(limit, 1)
	end

	# Build the template tree for this section recursively.
	protected fun tpl_tree_intern(limit, count: Int): Template do
		var out = new Template
		var index = index
		out.add "<li>"
		out.add tpl_link
		if (limit < 0 or count < limit) and
		   (children.length > 1 or (children.length == 1)) then
			out.add " <ul>"
			for child in children.values do
				if child == index then continue
				if child isa WikiArticle then
					out.add "<li>"
					out.add child.tpl_link
					out.add "</li>"
				else if child isa WikiSection and not child.is_hidden then
					out.add child.tpl_tree_intern(limit, count + 1)
				end
			end
			out.add " </ul>"
		end
		out.add "</li>"
		return out
	end
end

redef class WikiArticle

	redef fun out_path: String do
		if parent == null then
			return wiki.expand_path(wiki.config.out_dir, "{name}.html")
		else
			return wiki.expand_path(parent.out_path, "{name}.html")
		end
	end

	redef fun render do
		super
		if not is_dirty and not wiki.force_render then return
		wiki.message("Render article {name}", 2)
		var file = out_full_path
		file.dirname.mkdir
		tpl_page.write_to_file file
	end


	# Replace macros in the template by wiki data.
	private fun tpl_page: TemplateString do
		var tpl = wiki.load_template(template_file)
		if tpl.has_macro("TOP_MENU") then
			tpl.replace("TOP_MENU", tpl_menu)
		end
		if tpl.has_macro("HEADER") then
			tpl.replace("HEADER", tpl_header)
		end
		if tpl.has_macro("BODY") then
			tpl.replace("BODY", tpl_article)
		end
		if tpl.has_macro("FOOTER") then
			tpl.replace("FOOTER", tpl_footer)
		end
		return tpl
	end

	# Generate the HTML header for this article.
	fun tpl_header: Writable do
		var file = header_file
		if not wiki.has_template(file) then return ""
		return wiki.load_template(file)
	end

	# Generate the HTML page for this article.
	fun tpl_article: TplArticle do
		var article = new TplArticle
		article.body = content
		article.breadcrumbs = new TplBreadcrumbs(self)
		tpl_sidebar.blocks.add tpl_summary
		article.sidebar = tpl_sidebar
		return article
	end

	# Sidebar for this page.
	var tpl_sidebar = new TplSidebar

	# Generate the HTML summary for this article.
	#
	# Based on `headlines`
	fun tpl_summary: Writable do
		var headlines = self.headlines
		var tpl = new Template
		tpl.add "<ul class=\"summary list-unstyled\">"
		var iter = headlines.iterator
		while iter.is_ok do
			var hl = iter.item
			# parse title as markdown
			var title = wiki.inline_md(hl.title)
			tpl.add "<li><a href=\"#{hl.id}\">{title}</a>"
			iter.next
			if iter.is_ok then
				if iter.item.level > hl.level then
					tpl.add "<ul class=\"list-unstyled\">"
				else if iter.item.level < hl.level then
					tpl.add "</li>"
					tpl.add "</ul>"
				end
			else
				tpl.add "</li>"
			end
		end
		tpl.add "</ul>"
		return tpl
	end

	# Generate the HTML menu for this article.
	fun tpl_menu: Writable do
		var file = menu_file
		if not wiki.has_template(file) then return ""
		var tpl = wiki.load_template(file)
		if tpl.has_macro("MENUS") then
			var items = new Template
			for child in wiki.root_section.children.values do
				if child isa WikiArticle and child.is_index then continue
				if child isa WikiSection and child.is_hidden then continue
				items.add "<li"
				if self == child or self.breadcrumbs.has(child) then
					items.add " class=\"active\""
				end
				items.add ">"
				items.add child.tpl_link
				items.add "</li>"
			end
			tpl.replace("MENUS", items)
		end
		return tpl
	end

	# Generate the HTML footer for this article.
	fun tpl_footer: Writable do
		var file = footer_file
		if not wiki.has_template(file) then return ""
		var tpl = wiki.load_template(file)
		var time = new Tm.gmtime
		if tpl.has_macro("YEAR") then
			tpl.replace("YEAR", (time.year + 1900).to_s)
		end
		if tpl.has_macro("GEN_TIME") then
			tpl.replace("GEN_TIME", time.to_s)
		end
		return tpl
	end
end

# A `WikiArticle` that contains the sitemap tree.
class WikiSitemap
	super WikiArticle

	redef fun tpl_article do
		var article = new TplArticle.with_title("Sitemap")
		article.body = new TplPageTree(wiki.root_section, -1)
		return article
	end

	redef var is_dirty = false
end

# A `WikiArticle` that contains the section index tree.
redef class WikiSectionIndex

	redef var is_dirty = false

	redef fun tpl_article do
		var article = new TplArticle.with_title(section.title)
		article.body = new TplPageTree(section, -1)
		article.breadcrumbs = new TplBreadcrumbs(self)
		return article
	end
end

# Article HTML output.
class TplArticle
	super Template

	# Article title.
	var title: nullable Writable = null

	# Article HTML body.
	var body: nullable Writable = null

	# Sidebar of this article (if any).
	var sidebar: nullable TplSidebar = null

	# Breadcrumbs from wiki root to this article.
	var breadcrumbs: nullable TplBreadcrumbs = null

	# Init `self` with a `title`.
	init with_title(title: Writable) do
		self.title = title
	end

	redef fun rendering do
		if sidebar != null then
			add "<div class=\"col-sm-3 sidebar\">"
			add sidebar.as(not null)
			add "</div>"
			add "<div class=\"col-sm-9 content\">"
		else
			add "<div class=\"col-sm-12 content\">"
		end
		if body != null then
			add "<article>"
			if breadcrumbs != null then
				add breadcrumbs.as(not null)
			end
			if title != null then
				add "<h1>"
				add title.as(not null)
				add "</h1>"
			end
			add	body.as(not null)
			add " </article>"
		end
		add "</div>"
	end
end

# A collection of HTML blocks displayed on the side of a page.
class TplSidebar
	super Template

	# Blocks are `Stremable` pieces that will be rendered in the sidebar.
	var blocks = new Array[Writable]

	redef fun rendering do
		for block in blocks do
			add "<div class=\"sideblock\">"
			add block
			add "</div>"
		end
	end
end

# An HTML breadcrumbs that show the path from a `WikiArticle` to the `Nitiwiki` root.
class TplBreadcrumbs
	super Template

	# Bread crumb article.
	var article: WikiArticle

	redef fun rendering do
		var path = article.breadcrumbs
		if path.is_empty or path.length <= 2 and article.is_index then return
		add "<ol class=\"breadcrumb\">"
		for entry in path do
			if entry == path.last then
				add "<li class=\"active\">"
				add entry.title
				add "</li>"
			else
				if article.parent == entry and article.is_index then continue
				add "<li>"
				add entry.tpl_link
				add "</li>"
			end
		end
		add "</ol>"
	end
end

# An HTML tree that show the section pages structure.
class TplPageTree
	super Template

	# Builds the page tree from `root`.
	var root: WikiSection

	# Limits the tree depth to `max_depth` levels.
	var max_depth: Int

	redef fun rendering do
		add "<ul>"
		add root.tpl_tree(-1)
		add "</ul>"
	end
end
