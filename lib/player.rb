class Player
  attr_reader :psn_id, :level, :level_progress, :next_level_in, :country, :total_trophies, :total_platinums, :total_golds, :total_silvers, :total_bronzes, :games_played, :completed_games, :overall_completion, :unearned_trophies, :trophies_per_day, :world_rank, :country_rank, :recent_trophies, :recent_games, :rarest_trophies, :games_by_platform, :trophies_by_type, :average_rarity, :trophies_by_rarity, :average_completion, :trophies_by_completion, :first_trophy, :latest_trophy, :length_of_service

  # add attr_readers for all the keys in the scraped player_data hash, and add reader methods to get the sub-hashes/attributes
  # use meta-programming (#send) in #initialize to populate all the instance variables
  # add methods for putting (or returning?) each of the five collections of data outlined in the README in an easily readable format

  @@all = []

  def initialize(player_data)
    @psn_id = psn_id

    @average_rarity = self.rarity_breakdown[:average_rarity]
    @average_completion = self.completion_breakdown[:average_completion]
    @trophies_by_rarity = self.rarity_breakdown[:trophies_by_rarity]
    @trophies_by_completion = self.completion_breakdown[:trophies_by_completion]

    @@all << self
  end

  def self.all
    @@all
  end

  # delete method if the PSN ID is not scrapable?
end
