CC := ../spcomp64
INCLUDE := -i ../include -i include -i src -i sm-ripext/pawn/scripting/include
SRCS := gflbans
SRC_FILES := $(addprefix src/, $(addsuffix .sp, $(SRCS)))
DEPS := 
CC_FLAGS := 
TEST_FLAGS := -w203 -w204

gflbans: $(SRC_FILES) $(DEPS)
	$(CC) $(CC_FLAGS) $(SRC_FILES) $(INCLUDE) -o compiled/gflbans.smx

test_utils: $(SRC_FILES)
	$(CC) $(CC_FLAGS) $(TEST_FLAGS) test/gflbans_test_utils.sp src/utils.sp $(INCLUDE) -o compiled/tests/gflbans_test_utils.smx

test_infractions: $(SRC_FILES)
	$(CC) $(CC_FLAGS) $(TEST_FLAGS) test/init_globals.sp test/gflbans_test_infractions.sp src/infractions.sp src/log.sp test/api_mocks.sp src/utils.sp $(INCLUDE) -o compiled/tests/gflbans_test_infractions.smx

tests: test_utils test_infractions

.PHONY: all clean

all: gflbans tests

clean: 
	rm -f $(COMPILED)
