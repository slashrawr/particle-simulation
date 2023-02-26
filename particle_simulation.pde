int seed = 3315427;

int maxParticles = 3000;
Particle[] particles;

float attracRepel11 = 1;
float attracRepel12 = 1;
float attracRepel13 = -1;
float attracRepel14 = -1;
float attracRepel21 = -1;
float attracRepel22 = 1;
float attracRepel23 = -1;
float attracRepel24 = 1;
float attracRepel31 = -1;
float attracRepel32 = -1;
float attracRepel33 = -1;
float attracRepel34 = 1;
float attracRepel41 = -1;
float attracRepel42 = -1;
float attracRepel43 = 1;
float attracRepel44 = -1;

float force11 = 2.66f;
float force12 = 0.61f;
float force13 = 0.1f;
float force14 = 0.32f;
float force21 = 4.1f;
float force22 = 0.76f;
float force23 = 0.12f;
float force24 = 1.2f;
float force31 = 4.54f;
float force32 = 0.51f;
float force33 = 3.51f;
float force34 = 0.5f;
float force41 = 0.63f;
float force42 = 1.7f;
float force43 = 1.4;
float force44 = 4.3;

void setup() {
  size(1000,1000);
  frameRate(30);
  colorMode(HSB);
 
  randomSeed(seed);
 
  particles = new Particle[maxParticles];
  
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
    p.calcMotion(particles);
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
  
  Particle(int id, int type, color colour, float size, float forceRadius) {
    this.id = id;
    this.type = type;
    this.colour = colour;
    this.size = size;
    this.forceRadius = forceRadius;
    this.position = new PVector(random(width), random(height));
    this.acceleration = PVector.fromAngle(random(TWO_PI));
    this.velocity = PVector.fromAngle(random(TWO_PI));
  }
  
  void calcMotion(Particle[] particles) {
    
    ArrayList<Particle> nearParticles = getNearParticles(particles);
    PVector force = new PVector(0,0);
    for (Particle p : nearParticles) {
      force.add(getForce(p));      
    }
    
    this.velocity.add(force).mult(0.5);
    this.checkBounds();
    this.position.add(this.velocity);
  }
  
  
  ArrayList<Particle> getNearParticles(Particle[] particles) {
    ArrayList<Particle> nearParticles = new ArrayList<Particle>();
    
    for (int i = 0; i < particles.length; i++) {
      Particle p = particles[i];
      if (checkParticleDistance(p))
        nearParticles.add(p);
    }
    
    return nearParticles;
  }
  
  
  boolean checkParticleDistance(Particle otherParticle) {
    if (this.id == otherParticle.id)
      return false;
    
    if (this.position.dist(otherParticle.position) < otherParticle.forceRadius)
      return true;
    else
      return false;
  }
  
  PVector getForce(Particle particle) {
       
    PVector force = PVector.sub(particle.position,this.position);
    float distance = this.position.dist(particle.position);
    float mag = 0.0f;
       
    if (this.type == 1 && particle.type == 1) {
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
    }
    else if (this.type == 2 && particle.type == 1) {
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
    }
    else if (this.type == 3 && particle.type == 1) {
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
    }
    else if (this.type == 4 && particle.type == 1) {
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
    }
    
    force.normalize();
    force.mult(mag*sqrt(particle.size));
    
    return force;
  }
  
  void checkBounds() {  
    

    
    
    // Flow through
    if (this.position.x > width)
      this.position.x = this.position.x-width;
    else if (this.position.x < 0)
      this.position.x = width+this.position.x;
    
    if (this.position.y > height)
      this.position.y = this.position.y-height;
    else if (this.position.y < 0)
      this.position.y = height+this.position.y;
    
  }
}
