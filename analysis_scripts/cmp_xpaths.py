import sys
import pandas as pd
from fuzzywuzzy import fuzz

def similarity_partial_ratio(str1, str2):
    """Calculates the partial ratio similarity score between two strings."""
    return fuzz.partial_ratio(str1, str2)


def help_message():
    """Displays a help message explaining script usage."""
    print("Usage: script.py <string1> <string2>")
    print("Calculates the partial ratio similarity score between two strings.")
    print("  string1: The first string to compare.")
    print("  string2: The second string to compare.")


def main():
    """Main function to handle user input and script execution."""
    if len(sys.argv) < 3:  # Check for at least three arguments (script name + 2)
        print("Error: Please provide two strings for comparison.")
        help_message()
        return

    try:
        string1 = sys.argv[1]  # Access first user-provided argument
        string2 = sys.argv[2]  # Access second user-provided argument
        similarity = similarity_partial_ratio(string1, string2)
        print(f"Similarity Score (Partial Ratio): {similarity}")
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()

