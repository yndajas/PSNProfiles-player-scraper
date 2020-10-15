class PSNProfiles_player_scraper::Scraper
  BASE_PATH = "https://psnprofiles.com/"

  def self.open(psn_id)
    Nokogiri::HTML(OpenURI.open_uri(BASE_PATH + psn_id))
  end

  def self.valid_profile(psn_id)
    profile = PSNProfiles_player_scraper::Scraper.open(psn_id)
    # first check is if the URL redirected to the homepage (untracked profile)
    if profile.css("span.username").length == 0
      false
    # second check is if the player has public trophy data on their profile (via the message that displays for those who don't)
    elsif profile.css("h1").first != nil && profile.css("h1").first.text[0..2] == "Aww"
      false
    else
      profile
    end
  end

  def self.scrape(profile_data)
    player = {}

    # get data from top row (including mouseover extras)

    player[:psn_id] = profile_data.css("span.username").text.strip #this gets the username with the correct capitalisation

    player[:comment] = profile_data.css("span.comment").text if profile_data.css("span.comment").length > 0

    player[:level] = profile_data.css("li.icon-sprite.level").text

    player[:level_progress] = profile_data.css("div.progress-bar.level div").attribute("style").value.gsub("width: ","").gsub(";","")

    player[:next_level_in] = profile_data.search('script[type="text/javascript"]')[12].children.to_s.strip.gsub(/.*( in <b>)/,"").gsub("\n","").gsub(/(<\/b>).*/,"") + " points"

    player[:country] = profile_data.css("img.round-flags").attribute("title").text.gsub("<center style='font-size:11px;'>","").gsub("</center>","")

    player[:total_trophies] = profile_data.css("li.total").text.strip

    player[:total_platinums] = profile_data.css("li.platinum").text.strip

    player[:total_golds] = profile_data.css("li.gold").text.strip

    player[:total_silvers] = profile_data.css("li.silver").text.strip

    player[:total_bronzes] = profile_data.css("li.bronze").text.strip

    # get data from second row (of eight stats near top of profile)

    stats_flex = profile_data.css("span.stat.grow")

    stats_flex_data = stats_flex.collect do |stat|
      stat.to_s.gsub(/(<span).*(">)/,"").gsub(/(<span>).*/,"").gsub(/(<a).*(">)/,"").gsub(/(<\/a>)/,"").gsub(/(<\/span>)/,"").strip
    end

    stats_flex_data.delete_at(5) # delete (unwanted) profile views count

    stats_flex_data_keys = [:games_played, :completed_games, :overall_completion, :unearned_trophies, :trophies_per_day, :world_rank, :country_rank]

    stats_flex_data.each_with_index do |stat, i|
      player[stats_flex_data_keys[i]] = stat
    end

    # get recent trophies

    recent_trophies = []

    recent_trophies_scrape = profile_data.css("ul.recent-trophies.flex li")

    recent_trophies_scrape.length.times {recent_trophies << {}} # create empty hashes for each of the up to 12 recent trophies - I use the #length instead of 12.times so that it works for players with less than 12 total trophies

    recent_trophies_scrape.each_with_index do |trophy, i|
      recent_trophies[i][:trophy] = trophy.css("div.ellipsis a.title").text.strip
      recent_trophies[i][:game] = trophy.css("div.ellipsis span.small_info_green a").text.strip
      recent_trophies[i][:description] = trophy.css("div.ellipsis span")[0].text.strip
    end

    player[:recent_trophies] = recent_trophies

    # get recent games

    recent_games = []

    recent_games_scrape = profile_data.css('[id="gamesTable"] tr')

    if recent_games_scrape.length < 12 # create empty hashes for up to 12 recent games
      recent_games_scrape.length.times {recent_games << {}}
    else
      12.times {recent_games << {}}
    end

    recent_games_scrape[0..11].each_with_index do |game, i| # iterate over the most recent 12 games (`[0..11]` creates a subarray)
      recent_games[i][:game] = game.css("a.title").text

      if game.css("span.tag.platform").length > 1
        recent_games[i][:platform] = game.css("span.tag.platform").collect {|platform| platform.text}.join("/")
      else
        recent_games[i][:platform] = game.css("span.tag.platform").text
      end

      platinum_class = game.css("img.icon-sprite").attribute("class").value

      if platinum_class[12] == "c"
        recent_games[i][:platinum] = "not applicable (game has no platinum)"
      elsif platinum_class[-6..-1] == "earned"
        recent_games[i][:platinum] = "1"
      else
        recent_games[i][:platinum] = "0"
      end

      gsb_and_completion = game.css("div.trophy-count div span")

      recent_games[i][:golds] = gsb_and_completion[1].text
      recent_games[i][:silvers] = gsb_and_completion[3].text
      recent_games[i][:bronzes] = gsb_and_completion[5].text
      recent_games[i][:completion] = gsb_and_completion[6].text

      if game.css("div.small-info")[0].text.strip[0..2] == "All" # if the trophy count text starts "All", earned and available are both taken from the first bold tag, otherwise the first and second respectively
        recent_games[i][:earned_trophies] = game.css("div.small-info b")[0].text
        recent_games[i][:available_trophies] = game.css("div.small-info b")[0].text
      else
        recent_games[i][:earned_trophies] = game.css("div.small-info b")[0].text
        recent_games[i][:available_trophies] = game.css("div.small-info b")[1].text
      end

      if game.css("div.small-info")[1] == nil
        recent_games[i][:latest_trophy_date] = "not applicable (no trophies earned)"
      elsif game.css("div.small-info")[1].css("bullet").length > 0
        recent_games[i][:latest_trophy_date] = DateTime.parse(game.css("div.small-info")[1].text.strip.gsub(/\n.*/,""))

        speed_text = game.css("div.small-info")[1].text.strip.gsub("\n","").gsub(/.*(\u2022)/,"").gsub("\t","").strip.gsub("                                           ","")
        recent_games[i][:speedrun_type] = speed_text.gsub(/ .*/,"") == "Completed" ? "Completion" : "Platinum"
        recent_games[i][:speedrun_time] = speed_text.gsub(/.* in /,"").gsub(",", " and")
      else
        recent_games[i][:latest_trophy_date] = DateTime.parse(game.css("div.small-info")[1].text.strip)
      end

      completion_rates = game.css("span.separator.completion-status span")

      completion_rates.each do |completion_rate|
        completion_type = completion_rate.attribute("class").value
        completion_type[0] == "p" ? recent_games[i][:PSNProfiles_platinum_rarity] = completion_rate.text : recent_games[i][:PSNProfiles_completion_rarity] = completion_rate.text
      end
    end

    player[:recent_games] = recent_games

    # get rarest trophies

    rarest_trophies = []

    rarest_trophies_scrape = profile_data.css("div.sidebar.col-xs-4 div.box.no-top-border tr")

    rarest_trophies_scrape.length.times {rarest_trophies << {}}

    rarest_trophies_scrape.each_with_index do |trophy, i|
      rarest_trophies[i][:trophy] = trophy.css("td")[1].css("a")[0].text
      rarest_trophies[i][:game] = trophy.css("td")[1].css("a")[1].text
      rarest_trophies[i][:PSNProfiles_rarity] = trophy.css("td")[2].css("span")[0].text
      rarest_trophies[i][:grade] = trophy.css("td")[3].css("img").attribute("title").value
    end

    player[:rarest_trophies] = rarest_trophies

    # get data from /stats page

    stats_data = Nokogiri::HTML(OpenURI.open_uri(BASE_PATH + player[:psn_id] + "/stats"))

    games_by_platform = []

    games_by_platform_scrape = stats_data.css("div.col-xs-4")[0].css("ul.legend li")

    games_by_platform_scrape.length.times {games_by_platform << {}}

    games_by_platform_scrape.each_with_index do |platform, i|
      games_by_platform[i][:platform] = platform.text.gsub(/\(.*/,"").strip
      games_by_platform[i][:trophies] = platform.text.gsub(/.*\(/,"").gsub(")","")
    end

    player[:games_by_platform] = games_by_platform

    trophies_by_grade = [{},{},{},{}]

    trophies_by_grade_scrape = stats_data.css("div.col-xs-4")[1].css("ul.legend li")

    trophies_by_grade_scrape.each_with_index do |grade, i|
      trophies_by_grade[i][:grade] = grade.text.gsub(/\(.*/,"").strip
      trophies_by_grade[i][:trophies] = grade.text.gsub(/.*\(/,"").gsub(")","")
    end

    player[:trophies_by_grade] = trophies_by_grade

    rarity_breakdown = {:average_rarity => "",:trophies_by_rarity => [{},{},{},{},{}]}

    rarity_breakdown[:average_rarity] = stats_data.css("div.col-xs-4")[3].css("div.col-xs-6 span.typo-top").text

    trophies_by_rarity_scrape = stats_data.css("div.col-xs-4")[3].css("ul.legend li")

    trophies_by_rarity_scrape.each_with_index do |rarity_band, i|
      rarity_breakdown[:trophies_by_rarity][i][:rarity_band] = rarity_band.text.gsub(/\(.*/,"").strip
      rarity_breakdown[:trophies_by_rarity][i][:trophies] = rarity_band.text.gsub(/.*\(/,"").gsub(")","")
    end

    rarity_breakdown[:trophies_by_rarity].each do |rarity_hash|
      rarity_hash[:rarity_band] = "0 - 4.99% ('" + rarity_hash[:rarity_band] + "')" if rarity_hash[:rarity_band] == "Ultra Rare"
      rarity_hash[:rarity_band] = "5 - 9.99% ('" + rarity_hash[:rarity_band] + "')" if rarity_hash[:rarity_band] == "Very Rare"
      rarity_hash[:rarity_band] = "10 - 19.99% ('" + rarity_hash[:rarity_band] + "')" if rarity_hash[:rarity_band] == "Rare"
      rarity_hash[:rarity_band] = "20 - 49.99% ('" + rarity_hash[:rarity_band] + "')" if rarity_hash[:rarity_band] == "Uncommon"
      rarity_hash[:rarity_band] = "50 - 100% ('" + rarity_hash[:rarity_band] + "')"  if rarity_hash[:rarity_band] == "Common"
    end

    player[:rarity_breakdown] = rarity_breakdown

    # average completion/completion ranges

    completion_breakdown = {:average_completion => "",:games_by_completion => [{},{},{},{},{}]}

    completion_breakdown[:average_completion] = stats_data.css("div.col-xs-4")[4].css("div.col-xs-6 span.typo-top").text

    games_by_completion_scrape = stats_data.css("div.col-xs-4")[4].css("ul.legend li")

    games_by_completion_scrape.each_with_index do |completion_band, i|
      completion_breakdown[:games_by_completion][i][:completion_band] = completion_band.text.gsub(/\(.*/,"").strip
      completion_breakdown[:games_by_completion][i][:games] = completion_band.text.gsub(/.*\(/,"").gsub(")","")
    end

    player[:completion_breakdown] = completion_breakdown

    first_trophy_data = Nokogiri::HTML(OpenURI.open_uri(BASE_PATH + player[:psn_id] + "/log?dir=asc"))

    player[:first_trophy] = {}

    player[:first_trophy][:trophy] = first_trophy_data.css("a.title")[0].text
    player[:first_trophy][:game] = first_trophy_data.css("img.game")[0].attribute("title").value
    player[:first_trophy][:description] = first_trophy_data.css("td")[2].text.gsub(player[:first_trophy][:trophy],"").strip

    if first_trophy_data.css("td")[5].text.gsub("\n"," ").strip.gsub("\r","").gsub("\t","") != "Missing Timestamp"
      player[:first_trophy][:time] = DateTime.parse(first_trophy_data.css("td")[5].text.gsub("\n"," ").strip.gsub("\r","").gsub("\t",""))
    else
      player[:first_trophy][:time] = "unknown (missing timestamp)"
    end

    latest_trophy_data = Nokogiri::HTML(OpenURI.open_uri(BASE_PATH + player[:psn_id] + "/log"))

    player[:latest_trophy] = {}

    player[:latest_trophy][:trophy] = latest_trophy_data.css("a.title")[0].text
    player[:latest_trophy][:game] = latest_trophy_data.css("img.game")[0].attribute("title").value
    player[:latest_trophy][:description] = latest_trophy_data.css("td")[2].text.gsub(player[:latest_trophy][:trophy],"").strip

    if latest_trophy_data.css("td")[5].text.gsub("\n"," ").strip.gsub("\r","").gsub("\t","") != "Missing Timestamp"
      player[:latest_trophy][:time] = DateTime.parse(latest_trophy_data.css("td")[5].text.gsub("\n"," ").strip.gsub("\r","").gsub("\t",""))
    else
      player[:latest_trophy][:time] = "unknown (missing timestamp)"
    end

    player[:latest_trophy][:time] = DateTime.parse(latest_trophy_data.css("td")[5].text.gsub("\n"," ").strip.gsub("\r","").gsub("\t",""))

    if player[:first_trophy][:time] == player[:latest_trophy][:time]
      player[:length_of_service] = "not applicable (only one trophy)"
    elsif player[:first_trophy][:time].class == DateTime && player[:latest_trophy][:time].class == DateTime
      player[:length_of_service] = TimeDifference.between(player[:first_trophy][:time],player[:latest_trophy][:time]).humanize.downcase
    else
      player[:length_of_service] = "unknown (missing timestamp(s))"
    end

    player
  end
end
