

def main():
    """Main stuff"""
    print("I am: ", __name__, "main()")
    try:
        print("Importing")
        import lib_spid_test
        print("Success", lib_spid_test, dir(lib_spid_test))
    except Exception as e:
        print("Failed import", e)
    return True

def test_main():
    assert main() == True

if __name__ == "__main__":
    main()
