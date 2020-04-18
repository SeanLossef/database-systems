from lxml import etree


class ComposerPageQueryTool:

    def __init__(self, tree):
        self.tree = tree

    def run_query(self, query):
        return self.tree.xpath(query)

    """Return the number of pages with comments"""
    def count_comments(self):
        return self.run_query('count(/mediawiki/page[revision/comment])')

    """Return the number of pages for user id 5558"""
    def count_revisions_by_user(self):
        return self.run_query('count(/mediawiki/page[revision/contributor/id=5558])')

    """Return the timestamp for the 12th page revised by user 5558"""
    def contribution_timestamp(self):
        return self.run_query('string(/mediawiki/page[revision/contributor/id=5558][position()=12]/revision/timestamp)')

    """Return the number of pages with more than 1kb of content"""
    def count_larger_pages(self):
        return self.run_query('count(/mediawiki/page[revision/text/@bytes>1000])')

    """Return the username for the contributor who edited page 150096"""
    def page_reviser(self):
        return self.run_query('/mediawiki/page[id=150096]/revision/contributor/username')

    """Return the title of the composition that was revised at 2015-02-07T22:58:31Z"""
    def title_timestamp(self):
        return self.run_query('string(/mediawiki/page[revision/timestamp="2015-02-07T22:58:31Z"]/title)')

    """Return the number of pages where the composition title starts with "Sonata" """
    def count_sonata(self):
        return self.run_query('count(/mediawiki/page[starts-with(title, "Sonata")])')

    """Return the tag name for the third sibling of the text element containing the file: 
    PMLP137192-ariaperquestabel00moza.pdf"""
    def sibling_tag(self):
        return self.run_query('local-name(/mediawiki/page/revision/text[contains(text(), "PMLP137192-ariaperquestabel00moza.pdf")]/preceding-sibling::*[position()=2])')