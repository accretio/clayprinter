/* The Moineau pump, take from http://www.thingiverse.com/thing:7958 */

// https://www.atlanticsupply.com/wp-content/uploads/3L8CDQ-1.jpg


// crank();
//rotor();

/* The inlet */


/* The outlet */


//stator();
//gap();
//pumping_animated();

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

NozzleHeight=60;
NozzleOpening=4;

LoaderHeight=10;

v=4*R1*R2*H*360/phi;
echo(str("Pumping speed is ",v/1000," cc per revolution"));

module rotor(){
    
    union(){
        linear_extrude(height=H,convexity=20,twist=2*phi)
            translate([R1/2,0,0])
                circle(r=R2-c2);
         translate([0,0,-(4*LoaderHeight)])
               difference(){
                    cylinder(4*LoaderHeight, R2/2, R2/2);
                    translate([0, R2, 2*R2]) {
                            rotate([90, 0, 0]) {
                            cylinder(100, R2/4, R2/4);
                     }  
                 }
                } 
    }   
}



module hollow(Rc,Rr){
linear_extrude(height=H,convexity=10,twist=phi,slices=100)
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

module stator_base(gap) {
    translate([0, 0, 0]) {
    linear_extrude(height=BaseHeight,twist=720,slices=100)
                translate([BaseScrewThread, BaseScrewThread, 0])
                    circle(BaseRadius+gap, center=true);
    }
}

module stator(){
    translate([0, 0, H]) {
        rotate(phi) {
             nozzle(R1, R2+wall+c2);
        }
    }
    
    difference(){
        union() {
            hollow(R1,R2+wall);
            stator_base(R1); 
        }
        difference(){
            hollow(R1,R2);
        /* difference(){
           translate([0,0,wall-R1-R2]) 
             cube(size=2*R1+2*R2,center=true) ;
          hollow(R1+1.2*wall,R2+c2-1.2*wall);
        } */
    } 

}
}


InletOpening=10;
MotorOpening=R2/2; // make sure that there is enough room to put the rotor

LoaderSize=100;
LoaderHeight=80;
module loader() {
    difference(){
        union(){
            translate([0, 0, -LoaderHeight])
                sphere(r = 2 * (R1 + R2 + 3 * wall));
   
            translate([0, 0, -(LoaderHeight+BaseHeight)/2 + BaseHeight]) {
                cube(size=[LoaderSize, LoaderSize, LoaderHeight + BaseHeight], center=true);
            }; 
            translate([0, 0, 20])
                rotate([140, 00, 00])
                    cylinder(130, InletOpening+wall, InletOpening+wall); 
            
            translate([0, -75, -60])
                rotate([180, 0, 0])
                    cylinder(90, InletOpening+wall, (4*InletOpening)+wall);
            
        };
       stator_base();
        
        // let's put a stopper. it has to have straight lines or the printer won't be able to print it
        // (massive overhang)
       translate([-(LoaderSize-2*wall)/2, -(LoaderSize-2*wall)/2, -(LoaderHeight +wall)]) 
            cube(size=[LoaderSize -2*wall, LoaderSize -2*wall, LoaderHeight  ], center=false); 
   
       // then we carve the internals of the loader
       translate([-(LoaderSize-2*wall)/2, -(LoaderSize-2*wall)/2, -wall]) 
            cube(size=[LoaderSize-2*wall, LoaderSize-2*wall, wall], center=false);
        
      /* */
   
       // here is the motor opening 
       translate([0, 0, -LoaderSize])
               cylinder(2 * LoaderSize, MotorOpening, MotorOpening, center=true);
        
       // and this is the temporary feeding bowl
       translate([0, 0, -3*wall]) {
            linear_extrude(height=3*wall,convexity=10,twist=0,slices=100)
                circle(30);
            };
        
       translate([0, 0, 20]) {
            rotate([140, 0, 0])
                cylinder(125, InletOpening, InletOpening); 
       };
       
       translate([0, -75, -60])
            rotate([180, 0, 0])
                cylinder(90, InletOpening, (4*InletOpening));
       difference(){
            translate([0, 0, -LoaderHeight])
                sphere(r = 2 * (R1 + R2 + 2 * wall)); 
              translate([0, -75, -60])
                rotate([180, 0, 0])
                    cylinder(90, InletOpening+wall, (4*InletOpening)+wall);
         
        
       }; 
       
  }
    
}

