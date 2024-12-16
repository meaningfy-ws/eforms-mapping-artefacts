import pandas as pd
import argparse
import sys

def get_triples_map_name(file_path, sheet_name, field_id, iterator_column, node_id_column, class_column):
    # Read the specific sheet into a DataFrame
    df = pd.read_excel(file_path, sheet_name=sheet_name)

    # Check if the 'Field ID' column exists
    if 'Field ID' in df.columns:
        # Create a lowercase version of the 'Field ID' column for case-insensitive comparison
        df['Field ID Lower'] = df['Field ID'].astype(str).str.lower()
        field_id_lower = field_id.lower()  # Convert input field_id to lowercase

        # Find the row(s) with the specified Field ID
        matching_rows = df[df['Field ID Lower'] == field_id_lower]

        if not matching_rows.empty:
            # Return the corresponding 'TriplesMap Name' and 'Iterator XPath'
            iterator_values = matching_rows[iterator_column].tolist()
            triples_map_names = matching_rows['TriplesMap Name'].tolist()
            mapping_group_ids = matching_rows['Mapping Group ID'].tolist()

            # Extract tMapLabel from the first and second parts of the Mapping Group ID
            tMapLabels = [
                '-'.join(mg_id.split('-')[:2]) if '-' in mg_id else mg_id
                for mg_id in mapping_group_ids
            ]

            # Get the subject class from the specified class column
            subject_classes = matching_rows[class_column].tolist() if class_column in df.columns else [""] * len(matching_rows)

            # Get the node IDs
            node_ids = matching_rows[node_id_column].tolist() if node_id_column in df.columns else [""] * len(matching_rows)

            # Get the original field ID (not lowercased)
            original_field_ids = matching_rows['Field ID'].tolist()

            return list(zip(triples_map_names, iterator_values, tMapLabels, subject_classes, node_ids, original_field_ids))

    # If no matching Field ID, create tMapIri
    if 'Mapping Group ID' in df.columns:
        mapping_group_id = df['Mapping Group ID'].astype(str).tolist()
        # Use the specified node_id_column
        node_id_values = df[node_id_column].astype(str).tolist() if node_id_column in df.columns else [""] * len(mapping_group_id)

        tMapIri = []
        iterator_values = []
        subject_classes = []
        for mg_id, node_id in zip(mapping_group_id, node_id_values):
            tMapIri.append(f"{mg_id}_{node_id}")
            iterator_values.append("")  # Placeholder for iterator if not found
            subject_classes.append("")  # No subject class for this case

        return list(zip(tMapIri, iterator_values, subject_classes, node_id_values))  # No tMapLabel for this case

    return []

def get_name_from_rules(file_path, field_id, field_id_column, name_column):
    # Read the "Rules" sheet into a DataFrame
    rules_df = pd.read_excel(file_path, sheet_name='Rules')

    # Check if the specified columns exist
    if field_id_column in rules_df.columns and name_column in rules_df.columns:
        # Create a lowercase version of the field ID column for case-insensitive comparison
        rules_df[field_id_column + ' Lower'] = rules_df[field_id_column].astype(str).str.lower()
        field_id_lower = field_id.lower()  # Convert input field_id to lowercase

        # Find the row(s) with the specified field ID
        matching_row = rules_df[rules_df[field_id_column + ' Lower'] == field_id_lower]

        if not matching_row.empty:
            # Return the corresponding name
            return matching_row[name_column].values[0]

    return None

def get_relative_xpath(file_path, field_id, field_id_column, xpath_column):
    # Read the "Rules" sheet into a DataFrame
    rules_df = pd.read_excel(file_path, sheet_name='Rules')

    # Check if the specified columns exist
    if field_id_column in rules_df.columns and xpath_column in rules_df.columns:
        # Create a lowercase version of the field ID column for case-insensitive comparison
        rules_df[field_id_column + ' Lower'] = rules_df[field_id_column].astype(str).str.lower()
        field_id_lower = field_id.lower()  # Convert input field_id to lowercase

        # Find the row(s) with the specified field ID
        matching_row = rules_df[rules_df[field_id_column + ' Lower'] == field_id_lower]

        if not matching_row.empty:
            # Return the corresponding relative XPath
            return matching_row[xpath_column].values[0]

    return None

def generate_turtle_output(triples_map_iri, iterator, t_map_label, subject_class, node_id, base_iri, hashing_service_url, field_id, name, predicate, relative_xpath, is_relation, use_reference):
    # Strip off the prefix from subject_class
    stripped_subject_class = subject_class.split(':')[-1] if ':' in subject_class else subject_class
        
    if use_reference:
        template = f"if (exists(FIXME)) then '{base_iri}/id_' || replace(replace(/*/cbc:ID[@schemeName='notice-id'], ' ', '-' ), '/' , '-') || '_{stripped_subject_class}_' || unparsed-text('{hashing_service_url}' || encode-for-uri(path(FIXME)) || '?response_type=raw') else null" ;
        template_property = "rr:referenceEDITME"
    else:
        template = f"{base_iri}/id_{{replace(replace(/*/cbc:ID[@schemeName='notice-id'], ' ', '-' ), '/' , '-')}}_{stripped_subject_class}_{{unparsed-text('{hashing_service_url}' || encode-for-uri(path(FIXME)) || '?response_type=raw')}}"
        template_property = "rr:templateEDITME"
    
    # Format the comment
    comment = f"{name} of {t_map_label} under {node_id}"
    
    turtle_output = f"""
{triples_map_iri} a rr:TriplesMap ;
    rdfs:label "{t_map_label}" ;
    rml:logicalSource
        [
            rml:iterator "{iterator}" ;
        ] ;
    rr:subjectMap
        [
            rdfs:label "{node_id}" ;
            {template_property} "{template}" ;
            rr:class {subject_class} ;
        ] ;
    """
    
    # Include predicateObjectMap only if predicate is provided
    if predicate:
        turtle_output += f"""rr:predicateObjectMap
        [
            rdfs:label "{field_id}" ;
            rdfs:comment "{comment}" ;
            rr:predicate {predicate} ;
            rr:objectMap
                [
    """
        
        # Include either reference or parentTriplesMap based on is_relation
        if is_relation:
            turtle_output += f"""                rr:parentTriplesMap FIXME ;
                    rr:joinCondition [
                        rr:child "FIXME" ;
                        rr:parent "FIXME" ;
                    ] ;
            """
        else:
            turtle_output += f"""
                    rml:referenceCHECKME "{relative_xpath}" ;
            """
        
        turtle_output += """
                ] ;
        ] ;
    """
    
    return turtle_output

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Get TriplesMap Name or generate tMapIri based on Field ID.')
    parser.add_argument('-d', '--field', required=True, help='Field ID to look up')
    parser.add_argument('-f', '--file', required=True, help='Path to the Excel file')
    parser.add_argument('-s', '--sheet', default='Mapping groups with fields', help='Name of the sheet to read from')
    parser.add_argument('-i', '--iterator-column', default='Iterator XPath', help='Column name for the iterator')
    parser.add_argument('-n', '--node-id-column', default='Node ID (optional) or \nParent Node ID of Field', help='Column name for the Node ID lookup')
    parser.add_argument('-c', '--class-column', default='Instance Type (ontology Class)', help='Column name for the subject class lookup')
    parser.add_argument('-b', '--base-subject-iri', default='http://data.europa.eu/a4g/resource', help='Base IRI for subject map')
    parser.add_argument('-t', '--output-triples', action='store_true', help='Output RDF triples in Turtle syntax')
    parser.add_argument('-e', '--field-id-column', default='eForms SDK ID', help='Column name for the field ID in the Rules sheet')
    parser.add_argument('-m', '--name-column', default='Name', help='Column name for the name in the Rules sheet')
    parser.add_argument('-p', '--predicate', help='Predicate for the predicateObjectMap')
    parser.add_argument('-r', '--is-relation', action='store_true', help='Indicates that the predicate is a relation')
    parser.add_argument('-x', '--reference', action='store_true', help='Use rml:referenceEDITME instead of rr:templateEDITME')

    # If no arguments are provided, print help and exit
    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    # Parse arguments
    args = parser.parse_args()

    # Get the TriplesMap Name or tMapIri and iterator
    result = get_triples_map_name(args.file, args.sheet, args.field, args.iterator_column, args.node_id_column, args.class_column)

    # Get the comment from the Rules sheet based on the original field ID
    name = get_name_from_rules(args.file, args.field, args.field_id_column, args.name_column)

    # Get the relative XPath if predicate is provided
    relative_xpath = None
    if args.predicate:
        relative_xpath = get_relative_xpath(args.file, args.field, args.field_id_column, 'Relative XPath')

    # Print the result
    if result:
        if args.output_triples:
            for tMapIri, iterator, tMapLabel, subjectClass, nodeId, originalFieldId in result:
                turtle_output = generate_turtle_output(tMapIri, iterator, tMapLabel, subjectClass, nodeId, args.base_subject_iri, 'https://digest-api.ted-data.eu/api/v1/hashing/fn/uuid/', originalFieldId, name, args.predicate, relative_xpath, args.is_relation, args.reference)
                print(turtle_output.strip())
        else:
            print("tMapIri, Iterator, tMapLabel, Subject Class, Node ID:")
            for tMapIri, iterator, tMapLabel, subjectClass, nodeId, originalFieldId in result:
                print(f"{tMapIri}, {iterator}, {tMapLabel}, {subjectClass}, {nodeId}, {originalFieldId}")
    else:
        print("No matching Field ID found and no valid tMapIri could be generated.")

if __name__ == '__main__':
    main()
