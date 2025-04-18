import os
from lxml import etree
import argparse

def search_xpath_in_directory(directory, xpath, quiet_mode):
    # Walk through the directory and subdirectories
    matches = []  # List to store file matches
    for root_dir, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith(".xml"):  # Only process XML files
                file_path = os.path.join(root_dir, filename)
                try:
                    # Parse the XML file
                    tree = etree.parse(file_path)
                    root = tree.getroot()

                    # Get namespaces, including default (unnamed) namespace
                    namespaces = root.nsmap
                    if None in namespaces:  # Check for default namespace
                        # Assign the prefix 'ns0' to the default namespace
                        namespaces['ns0'] = namespaces.pop(None)

                    # Perform XPath query with namespaces
                    elements = tree.xpath(xpath, namespaces=namespaces)

                    # If matches are found, add the file to the list
                    if elements:
                        matches.append(file_path)
                        if not quiet_mode:  # Only print content if not in quiet mode
                            print(f"Matches in {file_path}:")
                            for elem in elements:
                                print(etree.tostring(elem, pretty_print=True, encoding="unicode"))

                except etree.XMLSyntaxError:
                    print(f"Error parsing {file_path}. Skipping...")

    # Print only the list of file matches in quiet mode
    if quiet_mode:
        for match in matches:
            print(match)

if __name__ == "__main__":
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Search for XPath in XML files within a directory recursively.")
    parser.add_argument("directory", help="Path to the directory containing XML files")
    parser.add_argument("xpath", help="XPath expression to search for")
    parser.add_argument("-q", "--quiet", action="store_true", help="Suppress content output and only list file matches")
    args = parser.parse_args()

    # Call the search function
    search_xpath_in_directory(args.directory, args.xpath, args.quiet)
