# PSNProfiles player scraper
Scrape PSNProfiles player pages using a command-line interface/terminal, then view individual data, export to XML/JSON or compare with another player.

You can view a demo of the app in action over on YouTube: <a href="https://www.youtube.com/watch?v=l1yA_LfLz-c" target="_blank" title="app demo on YouTube">youtube.com/watch?v=l1yA_LfLz-c</a>

[![YouTube demo](https://img.youtube.com/vi/l1yA_LfLz-c/hqdefault.jpg)](http://www.youtube.com/watch?v=l1yA_LfLz-c)

## Installation

Install Ruby (<a href="https://www.ruby-lang.org/en/documentation/installation" target="_blank" title="Ruby installation">help</a>), then in a terminal:
1. `gem install bundler`
2. change directory to PSNProfiles-profile-scraper<br>(e.g. `cd "C:\Users\yndaj\Downloads\PSNProfiles-profile-scraper"`)
3. `bundle install`

## Usage

In a terminal:
1. Make sure you're in the PSNProfiles-profile-scraper directory (via `cd`)
2. `ruby bin/scrape`

## Features

Retrieve the following collections of data about PlayStation players<sup>1</sup>, compare two players and export player data to XML/JSON.

### Basics
* PSN ID (as capitalised by the player) and comment
* current level and progress to next level (% and points to go)
* rank by world and country<sup>2</sup>
* basic stats:
  * overall completion rate<sup>3</sup>
  * average game completion rate<sup>4</sup>
  * average PSNProfiles trophy rarity
  * trophies per day (since first trophy)

### Totals
* trophies, platinums, golds, silvers and bronzes
* unearned trophies
* games played
* games completed

### Summaries (number of x by y)
* number of trophies by:
  * grade
  * rarity band<sup>5</sup>
* number of games by:
  * platform
  * completion band<sup>6</sup>

### Length of service (inc. first/latest trophy)
  * first trophy and latest trophy:
    * name
    * game
    * description
    * date/time earned
  * time between first and latest trophies ("length of service")

### Collections (recent trophies/games and rarest trophies)
* recent trophies (up to 12):
  * name
  * game
  * description
* recent games (up to 12):
  * title
  * platform
  * platinum, golds, silvers and bronzes
  * earned trophies, available trophies and completion percentage<sup>7</sup>
  * date of latest trophy earned
  * time to platinum/100%
  * rarity of platinum/100% on PSNProfiles
* rarest trophies (up to 5):
  * name
  * game
  * PSNProfiles rarity
  * type

## Notes

<sup>1</sup> the player must have been pre-scraped/updated by PSNProfiles. Once a player's data has been scraped for the first time by PSNProfiles, it will automatically be updated every 6 hours for the website's premium members, every 24 hours for regular members and every week for unregistered (but tracked) players. Data can be manually updated via the PSNProfiles homepage more frequently: once per minute for premium members and once per hour for everyone else. However, if a profile hasn't been manually updated in a while (the past month?), automatic updates will be suspended.

<sup>2</sup> of profiles tracked by PSNProfiles - see (1) for details about tracking.

<sup>3</sup> overall completion rate is a weighted percentage of non-platinum trophies earned across all games with at least one trophy earned. The weighting is by trophy type, as per the points each are worth on the PlayStation Network itself:
* platinum: 300 points (platinums are not included in the calculation)
* gold: 90 points
* silver: 30 points
* bronze: 15 points

<sup>4</sup> this is different to the overall completion rate - this is the average completion percentage of each of the player's games (so a game with two bronzes and a 50% completion percentage would have equal effect on the average as a game with 500 golds and a 50% completion rate, regardless of the trophy composition of any other games).

<sup>5</sup> rarity bands are as per PSNProfiles:
* 0 - 4.99% ('Ultra Rare')
* 5 - 9.99% ('Very Rare')
* 10 - 19.99% ('Rare')
* 20 - 49.99% ('Uncommon')
* 50 - 100% ('Common')

<sup>6</sup> completion bands as per PSNProfiles:
* 80 - 100%
* 60 - 79.99%
* 40 - 59.99%
* 20 - 39.99%
* 0 - 19.99%

<sup>7</sup> weighted by trophy type, including platinum - see (3) for points by type.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/yndajas/PSNProfiles-player-scraper](https://github.com/yndajas/PSNProfiles-player-scraper).

## Licence

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Disclaimer

This app and its creator have no affiliation with PSNProfiles or the PlayStation Network/PlayStation beyond the creator's use of both services.
