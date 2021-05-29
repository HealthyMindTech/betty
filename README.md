# bettingbee

Betting bee

## Getting Started with Flutter

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## What to bet on

* Finance: 
  * https://FXMarketAPI.com
  * https://marketstack.com/documentation
  * https://api-portal.etoro.com/
  * Challenge example: "The USD-HUF exchange rate will increase between 2021.05.01. 17:00 and 2021.05.01. 18:00" - the rate observation at the second timestamp will be greater than it is at the first timestamp.
* Active users/players on different platforms
  * Challenge example: "The number of active players at chess.com will decrease between 2021.05.01. 17:00 and 2021.05.01. 17:05" - the active player count at the second timestamp will be less than it is at the first timestamp. - https://www.chess.com/news/view/published-data-api
  * Players per country on chess.com: https://www.chess.com/news/view/published-data-api#pubapi-endpoint-country-players
* Weather (on earth, on mars)
  * on Earth: https://openweathermap.org/current
  * on Mars: https://api.nasa.gov/
* Air quality
  * https://openweathermap.org/api/air-pollution
* Covid / Pandemic
  * https://www.coronatracker.com/ (API: https://documenter.getpostman.com/view/11073859/Szmcbeho?version=latest)
* We could also allow gambling on other people success/failure. So say: I believe this player will lose his next five bets.
* Football
* Politics
* World events
* Entertainment
* Betting on vendor meetings bullshit bingo
* Betting on your own health
* Betting on house prices
* Betting on news: in the sense, will there come news about this figure in the next five minutes.
* Transport
  * https://api.tfl.gov.uk/
  * https://developers.google.com/transit/gtfs-realtime
* Wikipedia edits

### Platforms

* Metaforecast - Aggregator of some of the forecasting platforms, has a nice overview of the rest:
    * https://www.lesswrong.com/posts/cWSDKWDFcGA2Bzyni/introducing-metaforecast-a-forecast-aggregator-and-search
    * https://metaforecast.org/
    * https://github.com/QURIresearch/metaforecasts

* Ergo
    * https://ergo.ought.org/en/latest/index.html

* Foretold:
    * https://github.com/foretold-app/foretold 
    * https://www.foretold.io/

* GJopen:
    * https://www.gjopen.com/challenges/53-think-again-with-adam-grant
    * https://www.gjopen.com/challenges/50-the-economist-the-world-in-2021

* Metaculus:
    * https://www.metaculus.com/questions/

* Predictit:
    * https://www.predictit.org/

### Public data streams

For inspiration:

* https://ably.com/blog/ably-open-data-streaming-program
* https://ergo.ought.org/en/latest/index.html
* https://github.com/public-apis/public-apis
* https://api.nasa.gov/
* Bitcoin: https://api.coindesk.com/v1/bpi/currentprice.json
* https://www.freecodecamp.org/news/https-medium-freecodecamp-org-best-free-open-data-sources-anyone-can-use-a65b514b0f2d/
* https://www.programmableweb.com/category/real-time/api
* https://public-apis.io/
* https://datahelpdesk.worldbank.org/knowledgebase/articles/889386-developer-information-overview

Special waggers:

* https://mybookie.ag/sportsbook/special-wagers/
* https://www.oddsshark.com/entertainment
* https://www.pinnacle.com/en/entertainment/space/matchups/, https://www.pinnacle.com/en/soccer/england-premier-league/matchups/, https://www.pinnacle.com/en/soccer/uefa-euro/matchups/ -> https://github.com/pinnacleapi/OpenAPI-Specification

Unusual bets:

* https://mashable.com/2007/07/02/prediction-markets/?europe=true
* https://www.rd.com/list/weird-things-to-bet-on/
* https://sports.borgataonline.com/en/blog/weird-things-you-can-bet-on-in-the-absence-of-sports/: temperature, primary election voting, television ratings, esports
* osbscure sports: https://thebettingedge.co.uk/fancy-betting-on-sports-youve-probably-never-heard-of/ 


## Operations

* true/false
* will increase/descrease
* will increase/descrease by X
* will be over/under X
* between timestamp1 and timestamp2

