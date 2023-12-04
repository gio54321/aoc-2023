For this solution, the input is pre-processed because apparently, working with strings and parsing in COBOL is a big pain, so this is a quick and dirty way to not lose my mental sanity. 

```
python process_input.py > input_preprocessed.txt
make
./solution < input_preprocessed.txt
```