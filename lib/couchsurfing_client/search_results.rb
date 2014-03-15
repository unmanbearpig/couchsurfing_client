module CouchSurfingClient
  class SearchResults
    include Enumerable

    attr_reader :cs, :query, :pages

    def initialize query, search_pages = []
      @pages = search_pages
      @query = query
      @cs = query.cs
    end

    def each &block
      items.each(&block)
    end

    def count
      pages.reduce(0) { |count, page| count + page.count }
    end

    def items
      pages.map { |page| page.items }.flatten if pages
    end

    def get number_of_items_to_get = nil
      while number_of_items_to_get.nil? || (count < number_of_items_to_get)
        new_page = get_page(pages.length + 1)

        break unless new_page.success?
        break unless new_page.count && new_page.count > 0

        @pages << new_page
      end

      self
    end

    def get_page page_number
      page = nil
      if page_number == 1
        page = get_first_page
      else
        page = get_next_page page_number
      end

      page
    end

    def get_first_page
      cs.search_by_options query.options
    end

    def get_next_page page_num
      options = {
        'page' => page_num,
        'location' => query.options['location'],
        'search_mode' => query.options['search_mode'],
        'exclude_user_ids' => user_ids
      }

      cs.search_more_results_by_options options
    end

    def user_ids
      items.map { |item| item.profile_id }
    end
  end
end
