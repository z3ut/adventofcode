class Node:
    def __init__(self):
        self.childs = []
        self.metadata = []

def create_node(license_file, file_position):
    child_quantity = license_file[file_position]
    metadata_quantity = license_file[file_position + 1]
    current_file_position = file_position + 2
    node = Node()

    for i in range(child_quantity):
        child, current_file_position = create_node(license_file, current_file_position)
        node.childs.append(child)

    for i in range(metadata_quantity):
        node.metadata.append(license_file[current_file_position + i])

    current_file_position += metadata_quantity
    return (node, current_file_position)


with open("input.txt", "r") as f:
    license_file = list(map(int, f.readline().split()))


tree_root, _ = create_node(license_file, 0)

def calculate_metadata_sum(node, current_metadata_sum):
    node_metadata_sum = 0
    for c in node.childs:
        node_metadata_sum += calculate_metadata_sum(c, current_metadata_sum)
    node_metadata_sum += sum(node.metadata)
    return current_metadata_sum + node_metadata_sum

print(calculate_metadata_sum(tree_root, 0))


def calculate_value(node):
    if not node.childs:
        return sum(node.metadata)

    node_value = 0
    for m in node.metadata:
        if m <= len(node.childs):
            node_value += calculate_value(node.childs[m - 1])
    
    return node_value

print(calculate_value(tree_root))
