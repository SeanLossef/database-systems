from lxml import etree

parser = etree.XMLParser(ns_clean=True)

with open('long-data.xml', 'r') as file:
    tree = etree.parse(file, parser)
    print(parser.error_log)
    #result = tree.xpath('local-name(/mediawiki/page/revision/text[contains(text(), "PMLP137192-ariaperquestabel00moza.pdf")]/preceding-sibling::*[position()=2])')
    result = tree.xpath('/mediawiki/page[revision/contributor/id=5558][position()=12]/revision/timestamp/text()')
    print(result)

