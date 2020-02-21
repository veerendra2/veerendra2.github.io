FROM jekyll/builder
MAINTAINER Veerendra Kakumanu

RUN gem install jekyll bundler rdoc jekyll-sitemap \
	jekyll-feed jekyll-assets \
	jekyll-redirect-from jekyll-paginate

