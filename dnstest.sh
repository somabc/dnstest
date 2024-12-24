#!/bin/bash

# List of popular websites to test
websites=(
    "google.com"
    "facebook.com"
    "youtube.com"
    "amazon.com"
    "twitter.com"
    "wikipedia.org"
    "reddit.com"
    "instagram.com"
    "netflix.com"
    "linkedin.com"
)

# List of common public DNS resolvers with names
resolvers=(
    "1.1.1.1 (Cloudflare)"
    "1.0.0.1 (Cloudflare)"
    "8.8.8.8 (Google)"
    "8.8.4.4 (Google)"
    "208.67.222.222 (OpenDNS)"
    "208.67.220.220 (OpenDNS)"
    "9.9.9.9 (Quad9)"
    "149.112.112.112 (Quad9)"
    "64.6.64.6 (Verisign)"
    "64.6.65.6 (Verisign)"
)

# Get the default machine's DNS resolvers
machine_resolvers=$(nmcli dev show | grep DNS | awk '{print $2}')

# Add the machine's resolvers to the resolvers array with "(Machine)" label
for resolver in $machine_resolvers; do
    resolvers+=("$resolver (Machine)")
done

# Print the table header (condensed)
printf "%-15s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s" "Website" "CF1" "CF2" "G1" "G2" "OD1" "OD2" "Q1" "Q2" "V1" "V2" 
for resolver in "${machine_resolvers[@]}"; do
    printf "%-10s" "M($resolver)"  # Add machine resolver header
done
echo ""

# Loop through each website
for website in "${websites[@]}"; do
    printf "%-15s" "$website"

    # Loop through each resolver
    for resolver in "${resolvers[@]}"; do
        # Extract IP address from resolver string
        resolver_ip=$(echo "$resolver" | awk '{print $1}')

        # Use drill to query the website and measure the time taken
        time_taken=$(drill "@$resolver_ip" "$website" | grep "Query time" | awk '{print $4}')

        # Print the time taken (only the numeric value)
        printf "%-10s" "$time_taken" 
    done

    echo "" # Move to the next row
done
