import json

def sum_json(data, ignore_red=False):
    if isinstance(data, int):
        return data
    elif isinstance(data, list):
        return sum(sum_json(item, ignore_red) for item in data)
    elif isinstance(data, dict):
        if ignore_red and "red" in data.values():
            return 0
        return sum(sum_json(value, ignore_red) for value in data.values())
    return 0


def main():
    with open("input", "r") as f:
        values = json.load(f)

    print(sum_json(values))
    print(sum_json(values, ignore_red=True))
    print("Hello from day-12!")


if __name__ == "__main__":
    main()
