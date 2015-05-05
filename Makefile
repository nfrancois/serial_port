all: compile test

compile:
	pub run grinder:grinder compile   

test:
	pub run grinder:grinder test

