CPATH='.:lib/hamcrest-core-1.3.jar;lib/junit-4.13.2.jar'

# Clean up the directories
rm -rf student-submission
rm -rf grading-area
mkdir grading-area

echo "Starting script..."
git clone $1 student-submission
echo 'Finished cloning'

# Define directory names
SUBMISSION_DIR="student-submission" 
GRADING_DIR="grading-area"

# Define expected file names
EXPECTED_FILE="ListExamples.java"
STUDENT_CODE="$EXPECTED_FILE" # This assumes the expected file is ListExamples.java
TEST_FILE="TestListExamples.java" # Replace this with the actual test file name

# Check if the student's code is present
if [ ! -f "$SUBMISSION_DIR/$STUDENT_CODE" ]; then
 echo "Error: $STUDENT_CODE not found in the submission."
 exit 1
fi

# Validate the existence of the required class and methods
if ! grep -q "class ListExamples" "$SUBMISSION_DIR/$EXPECTED_FILE"; then
echo "Error: class 'ListExamples' not found in $EXPECTED_FILE."
exit 1
fi

if ! grep -q "static List<String> filter(List<String> list, StringChecker sc)" "$SUBMISSION_DIR/$EXPECTED_FILE"; then
echo "Could not find method 'filter'."
exit 1
fi

if ! grep -q "static List<String> merge(List<String> list1, List<String> list2)" "$SUBMISSION_DIR/$EXPECTED_FILE"; then
echo "Could not find method 'merge'."
exit 1
fi

# Copy the student code and test files to the grading area
#cp "$SUBMISSION_DIR/$STUDENT_CODE" "$GRADING_DIR"
#cp "$TEST_FILE" "$GRADING_DIR"
cp student-submission/*.java grading-area
cp TestListExamples.java grading-area

# Change to the grading directory to compile and run tests
cd "$GRADING_DIR"

# Copy the lib directory to the grading area
cp -r ../lib .

# Compile the student's code and test files
# Disable exit on error to handle potential compilation issues
set +e
#javac -cp "$CPATH" "$STUDENT_CODE" "$TEST_FILE" 2> compile_errors.txt
javac -cp ".;lib/hamcrest-core-1.3.jar;lib/junit-4.13.2.jar" *.java 2> compile_errors.txt


# Check for compilation errors
if [ $? -ne 0 ]; then
echo "Compilation failed. Please check your code."
cat compile_errors.txt
exit 1
fi

# Execute the tests and capture the results
#java -cp "$CPATH" org.junit.runner.JUnitCore TestListExamples 
java -cp ".;lib/junit-4.13.2.jar;lib/hamcrest-core-1.3.jar" org.junit.runner.JUnitCore TestListExamples > test_results.txt 2>&1
# Analyze the test results
# Simple parsing for JUnit output, more complex parsing may be required
# Provide feedback based on specific test failures
pwd
if grep -q "assertEqual" test_results.txt; then
echo "Hint: Use assertEquals to check content equality, not assertSame, which checks reference equality."
fi

if grep -q "a, b, c, d" test_results.txt; then
echo "Hint: The merge method should include duplicates in its result."
fi

if grep -q "FAILURES!!!" test_results.txt; then
echo "Some tests failed. Please check the test_results.txt."
exit 1
fi

# If all tests pass
echo "All tests passed. Congratulations!"
