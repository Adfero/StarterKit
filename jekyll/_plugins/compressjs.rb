module Jekyll
	class CompressJSFile < StaticFile
		def write(dest)
			# do nothing
		end
	end

	class CompressJSGenerator < Generator
		safe true

		def generate(site)
			config = Jekyll::CompressJSGenerator.get_config
			
			last_modified = File.mtime(config['js_main'])

			output_dir = File.join(site.config['destination'], config['js_destination_dir'])
			output_file = File.join(output_dir, config['js_destination_file'])

			# need to create destination dir if it doesn't exist
			FileUtils.mkdir_p(output_dir)
			minify_js(config['js_main'], output_file, site.config.has_key?('watch') == false)
			site.static_files << CompressJSFile.new(site, site.source, config['js_destination_dir'], config['js_destination_file'])
		end

		def minify_js(js_file, output_file, minify)
			minify = minify ? "" : "--minifyer \"\""
			juice_cmd = sprintf "juicer merge %s --force -s -i \"#{js_file}\" -o \"#{output_file}\"", minify
			puts juice_cmd
			system(juice_cmd)
		end

		def self.get_config
			if @config == nil
				@config = {
					'js_main' => '_js/main.js',
					'js_destination_dir' => '/js',
					'js_destination_file' => 'main.min.js'
				}
				config = YAML.load_file('CompressJS.yml') rescue nil
				if config.is_a?(Hash)
					@config = @config.merge(config)
				end
			end
			return @config
		end
	end

	class CompressJSLinkTag < Liquid::Tag
		def initialize(tag_name, text, tokens)
			super
		end

		def render(context)
			config = Jekyll::CompressJSGenerator.get_config
			File.join(config['js_destination_dir'],config['js_destination_file'])
		end
	end
end

Liquid::Template.register_tag('minified_js_file', Jekyll::CompressJSLinkTag)