class Player
  attr_reader :psn_id

  # add attr_readers for all the keys in the scraped player_data hash, and add reader methods to get the sub-hashes/attributes
  # use meta-programming (#send) in #initialize to populate all the instance variables
  # add methods for putting (or returning?) each of the five collections of data outlined in the README in an easily readable format

  @@all = []

  def initialize(player_data)
    @psn_id = psn_id
    @@all << self
  end

  def self.all
    @@all
  end

  # delete method if the PSN ID is not scrapable?
end
