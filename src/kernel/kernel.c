// VGA text mode constants
#define VGA_ADDRESS 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

// VGA color codes
#define COLOR_BLACK 0
#define COLOR_BLUE 1
#define COLOR_GREEN 2
#define COLOR_CYAN 3
#define COLOR_RED 4
#define COLOR_MAGENTA 5
#define COLOR_BROWN 6
#define COLOR_LIGHT_GREY 7
#define COLOR_DARK_GREY 8
#define COLOR_LIGHT_BLUE 9
#define COLOR_LIGHT_GREEN 10
#define COLOR_LIGHT_CYAN 11
#define COLOR_LIGHT_RED 12
#define COLOR_LIGHT_MAGENTA 13
#define COLOR_YELLOW 14
#define COLOR_WHITE 15

// Create color attribute byte
#define VGA_COLOR(fg, bg) ((bg << 4) | fg)

void clear_screen(void) {
    char *video_memory = (char*) VGA_ADDRESS;
    unsigned char color = VGA_COLOR(COLOR_WHITE, COLOR_BLACK);
    
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        video_memory[i * 2] = ' ';      // Character
        video_memory[i * 2 + 1] = color; // Attribute
    }
}

void print_string(const char *str, int x, int y, unsigned char color) {
    char *video_memory = (char*) VGA_ADDRESS;
    int offset = (y * VGA_WIDTH + x) * 2;
    
    for (int i = 0; str[i] != '\0'; i++) {
        video_memory[offset + i * 2] = str[i];
        video_memory[offset + i * 2 + 1] = color;
    }
}

void kernel_main(void) {
    // Clear the screen first
    clear_screen();
    
    // Print messages at different positions with different colors
    print_string("GORILLA MODE", 0, 0, VGA_COLOR(COLOR_LIGHT_GREEN, COLOR_BLACK));
    print_string("Screen cleared", 0, 1, VGA_COLOR(COLOR_LIGHT_CYAN, COLOR_BLACK));
    print_string("Kernel is running...", 0, 3, VGA_COLOR(COLOR_YELLOW, COLOR_BLACK));
    
    // Infinite loop
    while(1);
}