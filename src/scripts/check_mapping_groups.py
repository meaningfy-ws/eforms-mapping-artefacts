import pandas as pd
import argparse
import sys
import os
from rdflib import Graph, Namespace, RDF

def extract_triples_map_names_from_excel(file_path, sheet_name):
    # Read the specific sheet into a DataFrame
    df = pd.read_excel(file_path, sheet_name=sheet_name)
    # Extract the 'TriplesMap Name' column and remove duplicates
    return df['TriplesMap Name'].drop_duplicates().tolist()

def extract_triples_map_subjects_from_rdf(files):
    rr = Namespace("http://www.w3.org/ns/r2rml#")
    subjects = set()

    for file in files:
        g = Graph()
        g.parse(file, format='turtle')  # Adjust format if necessary
        for s in g.subjects(predicate=RDF.type, object=rr.TriplesMap):
            subjects.add(str(s))  # Convert to string to remove the namespace

    return list(subjects)

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Extract unique TriplesMap Names from an Excel file and RDF files.')
    parser.add_argument('-f', '--file', required=True, help='Path to the Excel file')
    parser.add_argument('-s', '--sheet', default='Mapping groups with fields', help='Name of the sheet to read from')
    parser.add_argument('-r', '--rdf', nargs='+', required=True, help='Paths to RDF files or directories containing RDF files')

    # If no arguments are provided, print help and exit
    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    # Parse arguments
    args = parser.parse_args()

    # Extract TriplesMap Names from Excel
    unique_triples_map_names = extract_triples_map_names_from_excel(args.file, args.sheet)

    # Remove the 'tedm:' prefix from the TriplesMap Names
    cleaned_triples_map_names = []
    for name in unique_triples_map_names:
        if isinstance(name, str):  # Ensure the name is a string
            cleaned_triples_map_names.append(name.replace('tedm:', ''))

    # Extract TriplesMap subjects from RDF files
    rdf_files = []
    for path in args.rdf:
        if os.path.isdir(path):
            rdf_files.extend([os.path.join(path, f) for f in os.listdir(path) if f.endswith('.ttl')])
        elif os.path.isfile(path) and path.endswith('.ttl'):
            rdf_files.append(path)

    unique_triples_map_subjects = extract_triples_map_subjects_from_rdf(rdf_files)

    # Remove the namespace from the subjects
    tedm_namespace = "http://data.europa.eu/a4g/mapping/sf-rml/"
    cleaned_triples_map_subjects = [subject.replace(tedm_namespace, '') for subject in unique_triples_map_subjects]

    # Compare the two lists
    cm_set = set(cleaned_triples_map_names)
    rdf_set = set(cleaned_triples_map_subjects)

    # Find items in CM that are not in RDF
    missing_in_rdf = cm_set - rdf_set

    # Print the difference
    print("Items in Conceptual Mapping not found in RDF:")
    print(*missing_in_rdf, sep='\n')

    # Calculate coverage percentage
    total_cm = len(cm_set)
    total_rdf = len(rdf_set)
    coverage_percentage = (total_rdf / total_cm * 100) if total_cm > 0 else 0

    print(f"\nCoverage of CM mapping groups among RDF: {coverage_percentage:.2f}%")

if __name__ == '__main__':
    main()
