# Prompt user to input the target domain name
read -p "Enter the domain name (e.g. example.com): " Domain

# Create a file to store the output
output_file="$Domain.txt"
touch $output_file

# Fetch subdomains from crt.sh and append to output file
curl -s https://crt.sh/?q=$Domain | grep $Domain | grep TD | sed 's/<BR>.*$//g' | sed 's/<\/TD>.*$//' | sed 's/<TD>//g' | sed 's/\*.//g' | sed 's/ //g' | grep -v "TDclass" | sort -u >> $output_file

# Use Amass to find subdomains and append to output file
amass enum --passive -d $Domain -o amass.txt
cat amass.txt | sort -u >> $output_file

# Use Subfinder to find subdomains and append to output file
subfinder -silent -recursive -d $Domain | sort -u | tee -a $output_file

# Use ParamSpider to find subdomains and append to output file
python3 ~/ParamSpider/paramspider.py -d $Domain --output ./paramspider.txt --level high
cat paramspider.txt | unfurl -u domain | sort -u >> $output_file

# Remove duplicate subdomains from output file
sort -u $output_file -o $output_file

# Print summary of subdomains found
echo "Subdomains found:"
cat $output_file