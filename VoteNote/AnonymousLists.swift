//
//  AnonymousLists.swift
//  VoteNote
//
//  Created by Wesley Curtis on 3/9/21.
//

import Foundation


///Grabbed this list of about 100 common adjectives to learn for new english speakers :)
let adjectivesList = ["Adorable", "Adventurous", "Aggressive", "Agreeable", "Alert", "Amused", "Angry", "Annoyed", "Annoying", "Anxious", "Arrogant", "Ashamed", "Attractive", "Average", "Awful", "Bad", "Beautiful", "Better", "Bewildered", "Blue", "Blue-eyed", "Blushing", "Bored", "Brainy", "Brave", "Breakable", "Bright", "Busy", "Calm", "Careful", "Cautious", "Charming", "Cheerful", "Clean", "Clear", "Clever", "Cloudy", "Clumsy", "Colorful", "Combative", "Comfortable", "Concerned", "Condemned", "Confused", "Cooperative", "Courageous", "Crazy", "Creepy", "Crowded", "Cruel", "Curious", "Cute", "Dangerous", "Dark", "Dead", "Defeated", "Defiant", "Delightful", "Depressed", "Determined", "Different", "Difficult", "Disgusted", "Distinct", "Disturbed", "Dizzy", "Doubtful", "Drab", "Dull", "Eager", "Easy", "Elated", "Elegant", "Embarrassed", "Enchanting", "Encouraging", "Energetic", "Enthusiastic", "Envious", "Evil", "Excited", "Expensive", "Exuberant", "Fair", "Faithful", "Famous", "Fancy", "Fantastic", "Fierce", "Filthy", "Fine", "Foolish", "Fragile", "Frail", "Frantic", "Friendly", "Frightened", "Funny", "Gentle", "Gifted", "Glamorous", "Gleaming", "Glorious", "Good", "Gorgeous", "Graceful", "Grieving", "Grotesque", "Grumpy", "Handsome", "Happy", "Healthy", "Helpful", "Helpless", "Hilarious", "Homeless", "Homely", "Horrible", "Hungry", "Hurt", "Ill", "Important", "Impossible", "Inexpensive", "Innocent", "Inquisitive", "Itchy", "Jealous", "Jittery", "Jolly", "Joyous", "Kind", "Lazy", "Light", "Lively", "Lonely", "Long", "Lovely", "Lucky", "Magnificent", "Misty", "Modern", "Motionless", "Muddy", "Mushy", "Mysterious", "Nasty", "Naughty", "Nervous", "Nice", "Nutty", "Obedient", "Obnoxious", "Odd", "Old-Fashioned", "Open", "Outrageous", "Outstanding", "Panicky", "Perfect", "Plain", "Pleasant", "Poised", "Poor", "Powerful", "Precious", "Prickly", "Proud", "Putrid", "Puzzled", "Quaint", "Real", "Relieved", "Repulsive", "Rich", "Scary", "Selfish", "Shiny", "Shrewd", "Shy", "Silly", "Sleepy", "Smiling", "Smoggy", "Sore", "Sparkling", "Splendid", "Spotless", "Stormy", "Strange", "Stupid", "Successful", "Super", "Talented", "Tame", "Tasty", "Tender", "Tense", "Terrible", "Thankful", "Thoughtful", "Thoughtless", "Tired", "Tough", "Troubled", "Ugliest", "Ugly", "Uninterested", "Unsightly", "Unusual", "Upset", "Uptight", "Vast", "Victorious", "Vivacious", "Wandering", "Weary", "Wicked", "Wide-eyed", "Wild", "Witty", "Worried", "Worrisome", "Wrong", "Zany", "Zealous"]

///most common animals
let animalsList = ["Aardvark", "Alligator", "Alpaca", "Anaconda", "Ant", "Antelope", "Ape", "Aphid", "Armadillo", "Asp", "Ass", "Baboon", "Badger", "Bald Eagle", "Barracuda", "Bass", "Basset Hound", "Bat", "Bear", "Beaver", "Bedbug", "Bee", "Beetle", "Bird", "Bison", "Black Panther", "Black Widow Spider", "Blue Jay", "Blue Whale", "Bobcat", "Buffalo", "Butterfly", "Buzzard", "Camel", "Caribou", "Carp", "Cat", "Caterpillar", "Catfish", "Cheetah", "Chicken", "Chimpanzee", "Chipmunk", "Cobra", "Cod", "Condor", "Cougar", "Cow", "Coyote", "Crab", "Crane", "Cricket", "Crocodile", "Crow", "Cuckoo", "Deer", "Dinosaur", "Dog", "Dolphin", "Donkey", "Dove", "Dragonfly", "Duck", "Eagle", "Eel", "Elephant", "Emu", "Falcon", "Ferret", "Finch", "Fish", "Flamingo", "Flea", "Fly", "Fox", "Frog", "Goat", "Goose", "Gopher", "Gorilla", "Grasshopper", "Hamster", "Hare", "Hawk", "Hippopotamus", "Horse", "Hummingbird", "Humpback Whale", "Husky", "Iguana", "Impala", "Kangaroo", "Ladybug", "Leopard", "Lion", "Lizard", "Llama", "Lobster", "Mongoose", "Monitor Lizard", "Monkey", "Moose", "Mosquito", "Moth", "Mountain Goat", "Mouse", "Mule", "Octopus", "Orca", "Ostrich", "Otter", "Owl", "Ox", "Oyster", "Panda", "Parrot", "Peacock", "Pelican", "Penguin", "Perch", "Pheasant", "Pig", "Pigeon", "Polar Bear", "Porcupine", "Quail", "Rabbit", "Raccoon", "Rat", "Rattlesnake", "Raven", "Rooster", "Sea Lion", "Sheep", "Shrew", "Skunk", "Snail", "Snake", "Spider", "Tiger", "Walrus", "Whale", "Wolf", "Zebra"]


///Literally just picks a random adjective and animal and joins them with a space
func generateAnonName() -> String {
  let adj = adjectivesList[Int.random(in: 0...adjectivesList.count-1)]
  let animal = animalsList[Int.random(in: 0...animalsList.count-1)]
  return adj + " " + animal
}

