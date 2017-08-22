import scrapy


class QuotesSpider(scrapy.Spider):
    name = "quotes"
    start_urls = [
        'https://www.socks-proxy.net/',
    ]

    def parse(self, response):
        pattern = r"document.write('(.+)')"
        for proxylist in response.css('div.table-responsive tbody'):
            cnt = 0
            for proxy in proxylist.css('tr'):
                cnt += 1
                tds = proxy.css('td::text').extract()
                if tds[4] == 'Socks4':
                    continue
                #tds = proxy.css('td::text').extract()
                #print (tds)
                yield {
                    'r': tds
                }

