include <elements.scad>


module panel() {
    difference(){
        translate([0, 0, BaseHeight/2]) {
            cube([180, 180, BaseHeight], center=true);
        }
        translate([-1.5 * BaseHeight, -1.6 * BaseHeight, 0]) {
            stator_base(0);
        }
        translate([-1.5 * BaseHeight, BaseHeight, 0]) {
            stator_base(0.2);
        }
        translate([1.1 * BaseHeight, 1.2 * BaseHeight, 0]) {
            stator_base(0.4);
        }
        translate([1.2 * BaseHeight, -1.4 * BaseHeight, 0]) {
            stator_base(0.6);
        }
    }
}

panel();