module AddThis
	class ShareLink < Liquid::Tag
		def initialize(name, params, tokens)
			super
			@service = params.delete(' ')
		end

		def render(context)
			site_url = context.registers[:site].config['url']
			page_path = context.environments.first["page"]["url"]

			url = "#{site_url}#{page_path}"
			title = context.environments.first["page"]["title"]
			teaser = context.environments.first["page"]["callout"].nil? ? "" : context.environments.first["page"]["callout"]
			pubid = context.registers[:site].config['addthis']['pubid']
			via = context.registers[:site].config['addthis']['via']
			text = title
			bitly_login = context.registers[:site].config['addthis']['bitly_login']
			bitly_key = context.registers[:site].config['addthis']['bitly_key']

			ShareLink::share_url(@service,url,title,teaser,pubid,via,text,bitly_login,bitly_key)
		end

		def self.share_url(service, url, title, teaser, pubid, via, text, bitly_login, bitly_key)
			require 'uri'
			servicename = service
			if service != 'default'
				service = 'forward/'+service+'/'
			else
				servicename = service
				service = ''
			end
			link = sprintf "http://api.addthis.com/oexchange/0.8/%soffer?url=%s&title=%s&description=%s&pubid=%s&via=%s&text=%s&shortener=bitly&bitly.login=%s&bitly.apiKey=%s", service, URI::escape(url), URI::escape(title), URI::escape(teaser), URI::escape(pubid), URI::escape(via), URI::escape(text), URI::escape(bitly_login), URI::escape(bitly_key)
			sprintf "<a href=\"%s\" rel=\"nofollow\" class=\"share-link share-%s\" target=\"_blank\" data-event=\"share-%s\">%s</a>", link, servicename, servicename, servicename
		end
	end
end

Liquid::Template.register_tag('sharelink', AddThis::ShareLink)