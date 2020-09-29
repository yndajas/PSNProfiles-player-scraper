class Player
  attr_accessor :psn_id
  
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