#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <limits>
#include <algorithm>
#include <iomanip>
#define CLEAR_SCREEN "clear" // use "cls" on microsoft windows and "clear" on unix based systems
#define WIDTH 90
void clearScreen() {
    system(CLEAR_SCREEN);
}
void loadItemsFromFile(std::vector<std::string>& items) {
    std::string filePath;
    std::cout << "Enter the directory path of the TXT file: ";
    std::getline(std::cin, filePath);
    std::ifstream file(filePath);
    if (!file) {
        std::cerr << "Error: File not found or could not be opened.\n";
        return;
    }
    std::string line;
    while (std::getline(file, line)) {
        items.push_back(line);
    }
    file.close();
    std::cout << "File loaded successfully.\n";
}
void manuallyEnterItems(std::vector<std::string>& items) {
    std::cout << "Enter items one by one (Enter 0 to finish): \n";
    std::string item;
    while (true) {
        std::getline(std::cin, item);
        if (item == "0") {
            break;
        }
        items.push_back(item);
    }
}
void displayItems(const std::vector<std::string>& items, const std::vector<bool>& status) {
    for (size_t i = 0; i < items.size(); ++i) {
        if (status[i]) {
            std::cout << "\033[1;32m" << i + 1 << ". " << items[i] << "\033[0m" << std::endl;
        } else {
            std::cout << "\033[1;31m" << i + 1 << ". " << items[i] << "\033[0m" << std::endl;
        }
    }
}
void xFnY(double x, std::ostream& y) {
    int xInt = static_cast<int>(x * 100);
    int xLeftPad = static_cast<int>(x * WIDTH);
    int xRightPad = WIDTH - xLeftPad;
    const std::string xColor = "\033[36m";
    const std::string xBold = "\033[1m";
    const std::string xReset = "\033[0m";
    std::string xBar;
    for (int i = 0; i < xLeftPad; ++i) {
        xBar += '|';
    }
    y << "\r\n" << xBold << std::setw(3) << xInt << "% [ " << xColor << xBar << xReset
      << std::string(xRightPad, ' ') << " ]\n" << std::flush;
}
void displayProgressBar(const std::vector<bool>& status) {
    int completedCount = std::count(status.begin(), status.end(), true);
    double progress = static_cast<double>(completedCount) / status.size();
    xFnY(progress, std::cout);
}
void toggleItem(std::vector<bool>& status) {
    int index;
	    bool allCompleted = std::all_of(status.begin(), status.end(), [](bool completed){ return completed; });
    if (allCompleted) {
        std::cout << "\nCongrats! You have finished all the tasks. Press 0 to exit, or other indexes to toggle completed list items: ";
    } else {
        std::cout << "\nEnter the index of the item to toggle completion (or 0 to exit): ";
    }
    std::cin >> index;
    if (index > 0 && index <= static_cast<int>(status.size())) {
        status[index - 1] = !status[index - 1];
    } else if (index == 0) {
        std::exit(0); 
	} else {
        std::cout << "Invalid index. Please try again.\n";
    }
}
int main() {
    std::vector<std::string> items;
    std::vector<bool> completionStatus;
    char choice;
    std::cout << "Load items from a file? (Y/N): ";
    std::cin >> choice;
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    if (choice == 'Y' || choice == 'y') {
        loadItemsFromFile(items);
    } else {
        manuallyEnterItems(items);
    }
    completionStatus.resize(items.size(), false);
    while (true) {
        clearScreen();
        displayItems(items, completionStatus);
        displayProgressBar(completionStatus);
        if (std::cin.fail()) {
            std::cin.clear(); 
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); 
        }
        toggleItem(completionStatus);
    }
    return 0;
}

