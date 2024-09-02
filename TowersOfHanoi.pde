import java.util.Stack;

int n_discs;
int[] discs;

float[] tower_x_coords, tower_y_coords;
float tower_thickness;
float max_radius, min_radius;
float disc_thickness;

float max_hue;

Stack<TowerFrame> alg_stack;
int max_stack_depth;

long step_size;
long swaps;

void setup() {
    // fullScreen();
    size(500, 500);
    windowResizable(true);
    windowTitle("Towers of Hanoi");

    colorMode(HSB, 365, 100, 100);
    textSize((float) min(height, width) / 30);

    n_discs = 5;
    discs = new int[n_discs];
    for (int i = 0; i < n_discs; i++) {
        discs[i] = 0;
    }

    tower_x_coords = new float[3];
    tower_x_coords[0] = (float) width / 4 * 1;
    tower_x_coords[1] = (float) width / 4 * 2;
    tower_x_coords[2] = (float) width / 4 * 3;
    tower_y_coords = new float[2];
    tower_y_coords[0] = (float) height / 6 * 1;
    tower_y_coords[1] = (float) height / 6 * 5;

    tower_thickness = (float) width * 0.01;

    max_radius = (float) width / 4 / 2 * 0.9;
    min_radius = (float) width / 4 / 2 * 0.3;
    disc_thickness = min((float) height / 20, (float) height * 4 / 6 / n_discs);

    max_hue = 340;

    alg_stack = new Stack<TowerFrame>();
    alg_stack.push(new TowerFrame(n_discs, 0, 2));
    max_stack_depth = 0;

    step_size = 1;
    swaps = 0;
}

void draw() {
    background(0);

    // Draw towers
    stroke(0, 0, 100);
    strokeWeight(tower_thickness);
    line(tower_x_coords[0], tower_y_coords[0], tower_x_coords[0], tower_y_coords[1]);
    line(tower_x_coords[1], tower_y_coords[0], tower_x_coords[1], tower_y_coords[1]);
    line(tower_x_coords[2], tower_y_coords[0], tower_x_coords[2], tower_y_coords[1]);

    // Draw discs
    int[] th = {1, 1, 1};
    strokeWeight(1);
    for (int i = 0; i < n_discs; i++) {
        float lrp_amnt = (n_discs > 1) ? ((float) i / (n_discs - 1)) : 0;
        float radius = lerp(max_radius, min_radius, lrp_amnt);
        float hue_color = lerp(0, max_hue, lrp_amnt);
        stroke(hue_color, 100, 100);
        fill(hue_color, 100, 100);
        rect(tower_x_coords[discs[i]] - radius, tower_y_coords[1] - (disc_thickness * th[discs[i]]), 2 * radius, disc_thickness * 0.9);
        th[discs[i]] += 1;
    }

    // Print step size
    strokeWeight(1);
    fill(0, 0, 255);
    
    String txt = "Step Size: " + step_size;
    text(txt, width - (textWidth(txt) * 1.2), textAscent() * 1.5);

    text("Discs: " + n_discs, 0, textAscent() * 1.5);
    text("Swaps: " + swaps, 0, textAscent() * 1.5 * 2);
    text("Stack depth : " + alg_stack.size(), 0, textAscent() * 1.5 * 3);
    text("Max stack depth : " + max_stack_depth, 0, textAscent() * 1.5 * 4);
}

int towerTopDisc(int tower) {
    for (int i = n_discs - 1; i >= 0; i--) {
        if (discs[i] == tower) return i;
    }
    return -1;
}

void towerAlgInc() {
    if (alg_stack.empty()) return;
    max_stack_depth = max(max_stack_depth, alg_stack.size());

    TowerFrame frame = alg_stack.peek();
    switch (frame.status) {
        case 0 :
            if (frame.n == 1) {
                // move disc src -> dst
                discs[towerTopDisc(frame.src)] = frame.dst;
                swaps++;
                // completed frame, pop out
                alg_stack.pop();
            } else {
                // add move n - 1, src -> tmp to stack
                frame.status++;
                alg_stack.push(new TowerFrame(frame.n - 1, frame.src, frame.tmp));
                towerAlgInc();
            }
            break;
        case 1 :
            // move disc src -> dst
            discs[towerTopDisc(frame.src)] = frame.dst;
            swaps++;
            frame.status++;
            break;
        case 2 :
            // add move n - 1, tmp -> dst to stack
            frame.status++;
            alg_stack.push(new TowerFrame(frame.n - 1, frame.tmp, frame.dst));
            towerAlgInc();
            break;
        case 3 :
            // completed frame, pop out
            alg_stack.pop();
            towerAlgInc();
            break;
    }
}

void resetSim(int n) {
    n_discs = n;
    discs = new int[n_discs];
    for (int i = 0; i < n_discs; i++) {
        discs[i] = 0;
    }

    disc_thickness = min(height / 20, height * 4 / 6 / n_discs);

    alg_stack = new Stack<TowerFrame>();
    alg_stack.push(new TowerFrame(n_discs, 0, 2));
    max_stack_depth = 0;

    step_size = 1;
    swaps = 0;
}

void keyPressed() {
    switch (keyCode) {
        case 39 : // RIGHT ARROW
            for (long i = 0; i < step_size; i++) {
                towerAlgInc();
            }
            break;	
        case 38 : // UP ARROW
            if (step_size < 4611686018427387904l) step_size *= 2;
            break;
        case 40 : // DOWN ARROW
            if (step_size > 1) step_size /= 2;
            break;
        case 82 : // R
            resetSim(n_discs);
            break;
        case 90 : // Z
            resetSim(n_discs > 1 ? n_discs - 1 : n_discs);
            break;
        case 88 : // X
            resetSim(n_discs + 1);
            break;
    }
}

void windowResized() {
    textSize((float) min(height, width) / 30);

    tower_x_coords[0] = (float) width / 4 * 1;
    tower_x_coords[1] = (float) width / 4 * 2;
    tower_x_coords[2] = (float) width / 4 * 3;
    tower_y_coords[0] = (float) height / 6 * 1;
    tower_y_coords[1] = (float) height / 6 * 5;

    tower_thickness = (float) width * 0.01;

    max_radius = (float) width / 4 / 2 * 0.9;
    min_radius = (float) width / 4 / 2 * 0.3;
    disc_thickness = min((float) height / 20, (float) height * 4 / 6 / n_discs);
}

class TowerFrame {
    int n, src, dst, tmp;

    // 0 : Hasnt Executed
    // 1 : n != 1, called n - 1, src -> tmp
    // 2 : n != 1, moved 1, src -> dst
    // 3 : n != 1, called n - 1, tmp -> dst
    int status;
    
    public TowerFrame(int n, int src, int dst) {
        this.n = n;
        this.src = src;
        this.dst = dst;
        this.tmp = 3 - src - dst;
        this.status = 0;
    }
}

