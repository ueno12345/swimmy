module Swimmy
    module Service
      class Anniversary

        # API仕様：https://www.mediawiki.org/wiki/API:Main_page
        WIKIPEDIA_URI = "https://ja.wikipedia.org/w/api.php?format=json&action=query&prop=revisions&pageids=456328&rvprop=content"

        def get_anniversay_event_titles_by_time(time)
          fetch_annual_anniversary_events
            .filter{ |it| it.occur_on?(time) }
            .map{ |it| it.title }
        end

        def fetch_annual_anniversary_events
          anniversaries = JSON.parse(URI.open(WIKIPEDIA_URI, &:read))["query"]["pages"]["456328"]["revisions"][0]["*"]

          parse_annual_anniversary_events(anniversaries)
        end

        def parse_annual_anniversary_events(anniversaries)
          anniversaries.scan(/^\*[^\d]*(\d+)\s*月[^\d]*(\d+)日[^-]*- (.*)/)
            .map{ |month, day, titles|
              titles.gsub(/[\[\]]/, "").split(/, /).map{ |title|
                Resource::Anniversary.new(month, day, title)
              }
            }.flatten
        end
        
      end # class Anniversary
    end # module Service
  end # module Swimmy
