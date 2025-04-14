from lxml import etree
import argparse

def get_parent_xpath(xpath):
    # Check if the XPath ends with an attribute (e.g., /@attributeName)
    if "/@" in xpath and xpath.strip().split("/")[-1].startswith("@"):
        # Remove the attribute part and return the parent XPath
        parent_xpath = xpath.rsplit("/@", 1)[0]  # Get everything before the /@
        return parent_xpath
    return xpath  # Return the original XPath if no attribute at the end

def query_xml_with_context(xml_file, absolute_xpath, relative_xpath):
    """
    Query XML file using an absolute XPath to set context and a relative XPath for the final query.
    Example: python test_rel_xpath.py test.xml "/*/ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/efext:EformsExtension/efac:Appeals/efac:AppealInformation/cbc:Title/@languageID" "../efbc:AppealStageCode"

    Args:
        xml_file (str): Path to the XML file
        absolute_xpath (str): Absolute XPath to set the context node
        relative_xpath (str): Relative XPath to query from the context node

    Returns:
        list: Results of the relative XPath query
    """
    # Load the XML file
    tree = etree.parse(xml_file)

    # Extract namespaces and replace any empty prefix with 'ns0'
    namespaces = tree.getroot().nsmap.copy()
    if None in namespaces:
        namespaces['ns0'] = namespaces.pop(None)

    # Get the context node using the absolute XPath
    context_parent = tree.xpath(get_parent_xpath(absolute_xpath), namespaces=namespaces)

    if context_parent:
        # Set the context node
        context_node = context_parent[0]

        # Perform the relative XPath query
        relative_query_results = context_node.xpath(relative_xpath, namespaces=namespaces)

        return relative_query_results
    else:
        return []

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Query XML file using absolute and relative XPaths')
    parser.add_argument('xml_file', help='Path to the XML file')
    parser.add_argument('absolute_xpath', help='Absolute XPath to set the context node')
    parser.add_argument('relative_xpath', help='Relative XPath to query from the context node')

    # Parse arguments
    args = parser.parse_args()

    # Query the XML
    results = query_xml_with_context(args.xml_file, args.absolute_xpath, args.relative_xpath)

    # Print results
    if results:
        for result in results:
            print("Result:", result.text)
    else:
        print("No results found or context node not found.")

if __name__ == "__main__":
    main()
