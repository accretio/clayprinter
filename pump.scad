/* The Moineau pump, take from http://www.thingiverse.com/thing:7958 */

// https://www.atlanticsupply.com/wp-content/uploads/3L8CDQ-1.jpg



//stator();
//rotor();

rotation = $t*360;
R1=10; // radius of rolling circle
R2=10; // radius of rotor
H=120; // height
wall=8*0.4*1.6; // wall thickness
top=3; // crank thickness
c1=0.2; // crank clearance
c2=0.0; // stator clearance
phi=450; // degrees of rotation of stator (>360)
$fn=40; // number of facets in circles

/// CONFIGURATION 

NozzleHeight=50;
NozzleOpening=10;

LoaderHeight=10;
RotorGap=0;
RotorScrewdriverDiameter=6;

v=4*R1*R2*H*360/phi;
echo(str("Pumping speed is ",v/1000," cc per revolution"));

module rotor(){
     translate([0, 0, -RotorGap]) {
     union(){
	  linear_extrude(height=H + rotorGap,convexity=20,twist=2*phi) {
	       translate([R1/2,0,0]) {
		    circle(r=R2-c2);
	       }
	  }
     }
     translate([0, 0, -20]) {
	  difference() {
	       cylinder(20, R1 * 2, R1 * 2 + wall);
	       translate([0, 0, 10])
		    rotate([90, 0, 0])
		    cylinder( (R1 * 2 + wall)*4, RotorScrewdriverDiameter/2, RotorScrewdriverDiameter/2, center=true);
	  }
     }
     }
}



module hollow(Rc,Rr, height=H){
     linear_extrude(height=height,convexity=10,twist=phi,slices=100)
	  union(){
	  translate([-Rc,0,0])
	       circle(r=Rr);
	  translate([Rc,0,0])
	       circle(r=Rr);
	  square([2*Rc,2*Rr],center=true);
// for a smoother mesh:
	  square([2/5*Rc,2.003*Rr],center=true);
	  square([5/5* Rc,2.002*Rr],center=true);
	  square([8/5*Rc,2.001*Rr],center=true);
     }
}


module nozzle(h, r1, r2) {
     translate([0, 0, - h/2]) 
        cylinder(h, r1, r2 = r2, center = true);
}


module base(Rc, Rr) {
    union(){
        translate([-Rc,0,0])
        circle(r=Rr);
        translate([Rc,0,0])
        circle(r=Rr);
        square([2*Rc,2*Rr],center=true);
        square([2/5*Rc,2.003*Rr],center=true);
        square([5/5* Rc,2.002*Rr],center=true);
        square([8/5*Rc,2.001*Rr],center=true);
    } 
}



/* The nozzle part. pretty much a WIP for now */

module nozzle(Rc, Rr) {
    module nozzleInternals(Rc, Rr) {
        intersection(){
            linear_extrude(height=NozzleHeight,convexity=10,twist=0,slices=100)
            base(Rc, Rr);
            cylinder(NozzleHeight, 1* (Rc + Rr), NozzleOpening);
        }
    }   
    difference(){
            nozzleInternals(Rc, Rr);
            union() {
                translate([0,0,-wall]){
                   cylinder(NozzleHeight+2*wall, NozzleOpening, NozzleOpening);   
                           
                    nozzleInternals(Rc, Rr-wall); 
                }
            }; 
    }
}


BaseRadius=15+2*R2; 
BaseHeight=30;
BaseScrewThread=2;
FeedingChamberHeight=20;
FeedingRampLength=4*R2+wall;

module feeding_chamber() {
    
	 translate([0, 0, -FeedingChamberHeight+wall]) {
	       difference()  {
		    union() {
			 cylinder(FeedingChamberHeight, 2*R2+wall+c2, 2*R2+wall+c2, $fn=100);
			 translate([0, 0, FeedingChamberHeight/2-wall/2])
			      rotate([90, 0, 0]) {
			      translate([2*R2-wall*1.5, 0, 0]) {
				   cylinder(FeedingRampLength, FeedingChamberHeight/2-wall/2, FeedingChamberHeight/2-wall/2);
				   translate([-FeedingChamberHeight/2+wall/2, -FeedingChamberHeight/2+wall/2, 0])
				   cube([2*FeedingChamberHeight/2-wall, FeedingChamberHeight/2-wall/2, FeedingRampLength]);
				   }
			 }
		    }
		    translate([0, 0, -wall])
			 cylinder(FeedingChamberHeight, 2*R2+c2, 2*R2+c2, $fn=100);

		    translate([0, 0, FeedingChamberHeight/2-wall/2]) {
			 rotate([90, 0, 0]) {
			      translate([2*R2-wall*1.5, 0, 0])
				   cylinder(FeedingRampLength, FeedingChamberHeight/2-wall, FeedingChamberHeight/2-wall);
			 }
		    }

		    translate([0, 0, FeedingChamberHeight-wall]) {
			 hollow(R1,R2);
		    }
	       }
	  }
	  
}
stator();


module stator(){

     // the body
     difference(){
	  hollow(R1,R2+wall);
	  hollow(R1,R2);
     }
     
     // the nozzle 
     translate([0, 0, H]) {
	  rotate(phi) {
	       nozzle(R1, R2+wall+c2);
	  }
     }

     // the feeding chamber
     feeding_chamber();
    
   
}

