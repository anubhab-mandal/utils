#!/bin/bash
generate_selectable_pdf_array() {
    pdf_files=()
    local i=0
    for file in *.pdf; do
        if [[ ! "$file" =~ _flattened\.pdf$ ]]; then
            pdf_files[i]="$file"
            ((i++))
        fi
    done
}
list_pdf_files() {
    printf "\nPDF files in the directory:\n\n"
    local i=1
    for file in "${pdf_files[@]}"; do
        echo "$i. $file"
        ((i++))
    done
}
draw_progress_bar() {
    local percent=$(($processed*100/$total_files))
    local equals=$(($percent / 2))
    local spaces=$((50 - equals))
    printf "\r["
    printf "%${equals}s" '' | tr - '='
    printf "%${spaces}s" '' | tr - -
    printf "] %d%% (%d/%d)" $percent $processed $total_files
}
process_files() {
    local total_files=$1
    local processed=0
    shift  # Skip first argument to loop through passed file indices
    
    local flattened_files=()  # To store names of flattened files for the potential renaming operation
    printf "\nStarting to flatten selected PDF files...\n"
    for index in "$@"; do
        local actual_index=$(($index-1))
        local file="${pdf_files[$actual_index]}"
        local flattened_file="${file%.pdf}_flattened.pdf"
        
        pdftk "$file" output "$flattened_file" flatten
        
        flattened_files+=("$flattened_file")
        ((processed++))
        
        draw_progress_bar
    done
    
    printf "\n\nSelected PDF files have been flattened.\n\n"
    ask_to_replace_originals "${flattened_files[@]}"
}
ask_to_replace_originals() {
    echo "Do you want to replace the original files with the flattened versions and remove '_flattened' from their names? (yes/no)"
    read replace_originals
    if [[ "$replace_originals" =~ ^[Yy][Ee][Ss]$ ]]; then
        for file in "$@"; do
            original_file="${file/_flattened/}"
            mv -f -- "$file" "$original_file"
        done
        echo "Original files have been replaced with the flattened versions."
        offer_downsample "${@/_flattened/}"  # Offer to downsample the now replaced files
    else
        echo "Keeping both original and flattened versions."
        offer_downsample "${@}"  # Offer to downsample the flattened files
    fi
}
offer_downsample() {
    echo "Do you want to downsample the images in the processed PDF files to DPI=120 for further size reduction? (yes/no)"
    read downsample_choice
    if [[ "$downsample_choice" =~ ^[Yy][Ee][Ss]$ ]]; then
        for file in "$@"; do
            gs -dBATCH -dNOPAUSE -dQUIET -sDEVICE=pdfwrite \
            -dDownsampleColorImages=true -dColorImageDownsampleType=/Bicubic -dColorImageResolution=120 \
            -dDownsampleGrayImages=true -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution=120 \
            -dDownsampleMonoImages=true -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=120 \
            -sOutputFile="${file%.pdf}_downsampled.pdf" "$file"
            echo "$file has been downsampled."
        done
    fi
}
generate_selectable_pdf_array
while true; do
    list_pdf_files
    echo -e "\nDo you want to flatten all PDFs ('all') or select ones only ('sel')?"
    read choice
    if [ "$choice" = "all" ]; then
        process_files ${#pdf_files[@]} $(seq 1 ${#pdf_files[@]})
    elif [ "$choice" = "sel" ]; then
        echo "Enter the numbers of the files you want to flatten, separated by spaces:"
        read -a indices
        process_files ${#indices[@]} "${indices[@]}"
    else
        echo "Invalid input. Please type 'all' or 'sel'."
        continue
    fi
    echo "Do you want to process more PDFs? (type 'yes' or 'no')"
    read answer
    if [ "$answer" != "yes" ]; then
        break
    fi
done
echo "Exiting the program."

