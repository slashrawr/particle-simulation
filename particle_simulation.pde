int seed = 354427;

int maxParticles = 3000;
Particle[] particles;

float attracRepel11 = 1;
float attracRepel12 = 1;
float attracRepel13 = -1;
float attracRepel14 = 1;
float attracRepel21 = -1;
float attracRepel22 = 1;
float attracRepel23 = -1;
float attracRepel24 = 1;
float attracRepel31 = -1;
float attracRepel32 = 1;
float attracRepel33 = -1;
float attracRepel34 = -1;
float attracRepel41 = -1;
float attracRepel42 = -1;
float attracRepel43 = -1;
float attracRepel44 = -1;

float force11 = 2.66f;
float force12 = 1.61f;
float force13 = 0.1f;
float force14 = 3.32f;
float force21 = 4.1f;
float force22 = 0.76f;
float force23 = 0.62f;
float force24 = 1.2f;
float force31 = 4.54f;
float force32 = 30.51f;
float force33 = 3.51f;
float force34 = 30.5f;
float force41 = 0.63f;
float force42 = 10.7f;
float force43 = 10.4;
float force44 = 0.3;

//Global for performance
PVector zeroVector = new PVector(0,0);
ArrayList<ParticleDistance> nearParticles = new ArrayList<ParticleDistance>();

ArrayList<Particle>[] sectors = new ArrayList[9];
int[][] sectorMapping;

FloatDict nearParticles2 = new FloatDict();

void setup() {
  size(1000,1000,P3D);
  frameRate(30);
  colorMode(HSB);
 
  randomSeed(seed);
 
  particles = new Particle[maxParticles];
  
  for (int i = 0; i < 9; i++) {
    sectors[i] = new ArrayList<Particle>();
  }
  
  sectorMapping = new int[][]{
    {0,1,3,4},
    {0,1,2,3,4,5},
    {1,2,4,5},
    {0,1,3,4,6,7},
    {0,1,2,3,4,5,6,7,8},
    {1,2,4,5,7,8},
    {3,4,6,7},
    {3,4,5,6,7,8},
    {4,5,7,8}};
  
  float p1Size = random(2,5);
  float p2Size = random(2,5);
  float p3Size = random(2,5);
  float p4Size = random(2,5);
  
  float p1ForceRadius = random(100,180);
  float p2ForceRadius = random(100,180);
  float p3ForceRadius = random(100,180);
  float p4ForceRadius = random(100,180);
  
  color p1Color = color(random(255), random(255), random(255));
  color p2Color = color(random(255), random(255), random(255));
  color p3Color = color(random(255), random(255), random(255));
  color p4Color = color(random(255), random(255), random(255));
  
  for (int i = 0; i < maxParticles; i++) {
    int type = floor(random(1,5));
    Particle particle;

    switch (type) {
      case 1 :        
        particle = new Particle(i, type, p1Color, p1Size, p1ForceRadius);
        particles[i] = particle;
        break;
      case 2 :        
        particle = new Particle(i, type, p2Color, p2Size, p2ForceRadius);
        particles[i] = particle;
        break;
      case 3 :        
        particle = new Particle(i, type, p3Color, p3Size, p3ForceRadius);
        particles[i] = particle;
        break;
      case 4 :        
        particle = new Particle(i, type, p4Color, p4Size, p4ForceRadius);
        particles[i] = particle;
        break;
    }
  }
  
  
}

void draw() {
  background(120);
  for (int i = 0; i < maxParticles; i++) {
    Particle p = particles[i];
    strokeWeight(p.size);
    stroke(p.colour);
    fill(p.colour);
    p.calcMotion();
    circle(p.position.x, p.position.y, p.size);
  }
}

class Particle {
 
  int id;
  int type;
  int colour;
  float size;
  float forceRadius;
  PVector position;
  PVector acceleration;
  PVector velocity;
  int sector; //used for performance
  
  Particle(int id, int type, color colour, float size, float forceRadius) {
    this.id = id;
    this.type = type;
    this.colour = colour;
    this.size = size;
    this.forceRadius = forceRadius;
    this.position = new PVector(random(width), random(height));
    this.acceleration = PVector.fromAngle(random(TWO_PI));
    this.velocity = PVector.fromAngle(random(TWO_PI));
    checkSector();
  }
  
  void calcMotion() {
    checkSector();
    getNearParticles();
    PVector force = zeroVector.copy();
  
    for (ParticleDistance pd : nearParticles) {
      force.add(getForce(pd.particle, pd.distance));      
    }
    
    this.velocity.add(force).mult(0.5);
    this.checkBounds();
    this.position.add(this.velocity);
  }
  
  void getNearParticles() {
    //SECTOR MAPPING
    //0 = 0,1,3,4
    //1 = 0,1,2,3,4,5
    //2 = 1,2,4,5
    //3 = 0,1,3,4,6,7
    //4 = 0,1,2,3,4,5,6,7,8
    //5 = 1,2,4,5,7,8
    //6 = 3,4,6,7
    //7 = 3,4,5,6,7,8
    //8 = 4,5,7,8
    
    nearParticles.clear();
    
    for (int sectorIndex = 0; sectorIndex < sectorMapping[this.sector].length; sectorIndex++) {
      int sector = sectorMapping[this.sector][sectorIndex];
      for (Particle p : sectors[sector]) {
         checkParticleDistance(p);
      }
    }
  }
  
  void checkParticleDistance(Particle otherParticle) {
    
    
    if (this.id == otherParticle.id)
      return;
   
    
    float d = this.position.dist(otherParticle.position);
    if (otherParticle.forceRadius > d) {
      ParticleDistance pd = new ParticleDistance(otherParticle, d);
      nearParticles.add(pd);
      return;
    }
    else
      return;
      
      //TODO: add handling for radius when it extends beyond bounds
  }
  
  PVector getForce(Particle particle, float distance) {
       
    PVector force = PVector.sub(particle.position,this.position);
    float mag = 0.0f;
    
    
    switch (this.type) {
     case 1 : if (this.type == 1 && particle.type == 1) {
          mag = (force11 / distance) * attracRepel11;
        }
        else if (this.type == 1 && particle.type == 2) {
          mag = (force12 / distance) * attracRepel12;
        }
        else if (this.type == 1 && particle.type == 3) {
          mag = force13 / distance * attracRepel13;
        }
        else if (this.type == 1 && particle.type == 4) {
          mag = force14 / distance * attracRepel14;
        };
     break;
     case 2:
     if (this.type == 2 && particle.type == 1) {
      mag = force21 / distance * attracRepel21;
    }
    else if (this.type == 2 && particle.type == 2) {
      mag = force22 / distance * attracRepel22;
    }
    else if (this.type == 2 && particle.type == 3) {
      mag = force23 / distance * attracRepel23;
    }
    else if (this.type == 2 && particle.type == 4) {
      mag = force24 / distance * attracRepel24;
    };
     break;
     case 3: if (this.type == 3 && particle.type == 1) {
      mag = force31 / distance * attracRepel31;
    }
    else if (this.type == 3 && particle.type == 2) {
      mag = force32 / distance * attracRepel32;
    }
    else if (this.type == 3 && particle.type == 3) {
      mag = force33 / distance * attracRepel33;
    }
    else if (this.type == 3 && particle.type == 4) {
      mag = force34 / distance * attracRepel34;
    };
     break;
     case 4: if (this.type == 4 && particle.type == 1) {
      mag = force41 / distance * attracRepel41;
    }
    else if (this.type == 4 && particle.type == 2) {
      mag = force42 / distance * attracRepel42;
    }
    else if (this.type == 4 && particle.type == 3) {
      mag = force43 / distance * attracRepel43;
    }
    else if (this.type == 4 && particle.type == 4) {
      mag = force44 / distance * attracRepel44;
    };
     break;
      
    }
    
    force.normalize();
    force.mult(mag*sqrt(particle.size));
    
    return force;
  }
  
  //Shift the particle to the opposite side if it goes out of bounds
  void checkBounds() {  
    if (this.position.x > width)
      this.position.x = this.position.x-width;
    else if (this.position.x < 0)
      this.position.x = width+this.position.x;
    
    if (this.position.y > height)
      this.position.y = this.position.y-height;
    else if (this.position.y < 0)
      this.position.y = height+this.position.y;
  }
  
  void checkSector() {
    
    int x = floor(this.position.x / (width / 3));
    int y = floor(this.position.x / (width / 3));
    int sector = -1;
    
    if (x == 0 && y == 0)
      sector = 0;
    else if (x == 1 && y == 0)
      sector = 1;
    else if (x == 2 && y == 0)
      sector = 2;
    else if (x == 0 && y == 1)
      sector = 3;
    else if (x == 1 && y == 1)
      sector = 4;
    else if (x == 2 && y == 1)
      sector = 5;
    else if (x == 0 && y == 2)
      sector = 6;
    else if (x == 1 && y == 2)
      sector = 7;
    else if (x == 2 && y == 2)
      sector = 8;
      
    if (sector == this.sector || sector == -1)
      return;
    else
      setSector(sector);
  }
  
  void setSector(int sector) {
    
    sectors[this.sector].remove(this);
    sectors[sector].add(this);    
    this.sector = sector;
  }
}

class ParticleDistance {
  
  Particle particle;
  float distance;
  
  ParticleDistance(Particle particle, float distance) {
    this.particle = particle;
    this.distance = distance;
  }
}
