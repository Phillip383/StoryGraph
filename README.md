# StoryGraph
A node-based story architecting tool inspired by Unreal Engine’s Blueprints, designed to empower narrative designers with a visual interface for laying out storylines, dialogue flows, and quest logic. Story structures can be exported to various formats—JSON, CSV, or XML—for seamless integration into game engines and narrative systems.


# Explanation of features and design
The application will have story graphs. Every main node in the graph will be its own unique storyline, or plot point, and it will connect via a line to the next node, which represents the next quest/dialog/plot in the story.

The main nodes can be encapsulated as you would chunks of logic in blueprints as functions, except they'll be called storylines within the application. You will be able to quickly search a list of all storylines and access them via visual searching or by name. This will keep the main graph clean, and easier to focus on the story line you're working on without the clutter from other nodes in the main graph. As long as the storyline is a part of that main graph. All of the data from it will be included in the final product.

Another important consideration I have accounted for is those quests or plots that will take you to a different level. There will be a special built-in node called a 'link' that will take in input to link the current node to a storyline in a different graph. This will essentially create/copy the data from that node into the final product for the two graphs, so you don't have to load an entire level's story data to get one quest, or have to worry about adding that story in the zone it links to. The application will do that for you. An idea of how to handle this on your end is every time a level is loaded, run a routine after the story data is loaded to compare active stories in the player's quest log to story IDs in that level and update the status of that quest in the level. 

Each story graph will be its own file when exported. This is important, and I chose this design because, when considering games, they often have their own levels and narrative structures. Think of World of Warcraft as an example, you can have a story graph for each zone that contains the quests of that zone, so elwynn_forest.csv
will have all of the quest data within it for that zone.

The application will export to JSON and CSV for sure. I'm considering XML; each CSV could be uploaded to a database with its own table. This will keep it clean instead of having thousands of quests in one file or table, which would have to be loaded unnessarly. You only have to load the data needed for the level the player is currently in. 

The application will automatically assign an incrementing id, or you can change the stucture of how you would like this id to be represented. You will have the option to restart the node id on each story graph, or keep the current id and follow up with it in the story graph, so if graph 1 has 100 nodes, graph 2 will start at 101. I chose to make this customizable because every game has a different structure, and I want this application to be as agnostic as possible. 


# Ambitious features I want to add. 

I also intend to write plugins for each of the three big engines, Godot, Unreal Engine, and Unity, to quickly parse and link your quest and dialog data to your game logic, but that will come in time. 

Opening and live updating pre-existing JSON and CSV graph files, instead of having to export updates and reimport them into the engine. This ties into partly why I want to write plugins for the engines. 

Since the graph-based system is just a visual representation of data, I plan on incorporating git as version control. 

I also want to add conditions to storylines, prerequisites, so a designer can make sure a player can't get a certain storyline without completing a set of quests or an entire storyline. 

Adding a debug feature to walk the designer through the story flow at a set rate. I feel like this visual representation can help designers ensure they have the correct flow. 
