#pragma once

#include "Particle.h"
#include <deque>

/*
 maxParticles describes how many particles are allowed
 in each leaf. a normal quadtree only has 1 particle per
 leaf. this can cause issues if two particles are very close
 together, as it causes a large number of subdivisions.
 in an evenly distributed system, if maxParticles has a high
 value, the tree will approximate a binning system.
*/
#define maxParticles 4

class Tree : public Body {
public:
	int nParticles;
	Particle* particles[maxParticles];
	bool hasChildren;
	Tree *nw, *ne, *sw, *se;
	float minX, minY, midX, midY, maxX, maxY;

	Tree() :
		nParticles(0),
		hasChildren(false),
		minX(0), minY(0),
		midX(0), midY(0),
		maxX(0), maxY(0) {
	}
	Tree(float _minX, float _minY, float _maxX, float _maxY) :
		nParticles(0),
		hasChildren(false),
		minX(_minX), minY(_minY),
		maxX(_maxX), maxY(_maxY) {
		setMid();
	}
	~Tree() {
		if(hasChildren) {
			delete nw;
			delete ne;
			delete sw;
			delete se;
		}
	}
	void setMid() {
		midX = (minX + maxX) / 2;
		midY = (minY + maxY) / 2;
	}
	void add(Particle& cur) {
		if(hasChildren) {
			if(cur.x < midX) {
				if(cur.y < midY) {
					nw->add(cur);
				} else {
					sw->add(cur);
				}
			} else {
				if(cur.y < midY) {
					ne->add(cur);
				} else {
					se->add(cur);
				}
			}
		} else {
			if(nParticles < maxParticles) {
				particles[nParticles] = &cur;
				nParticles++;
			} else {
				nw = new Tree(minX, minY, midX, midY);
				ne = new Tree(midX, minY, maxX, midY);
				sw = new Tree(minX, midY, midX, maxY);
				se = new Tree(midX, midY, maxX, maxY);
				hasChildren = true;
				for(int i = 0; i < nParticles; i++)
					add(*particles[i]);
				nParticles = 0;
				add(cur);
			}
		}
	}
	void setup(vector<Particle>& all) {
		int n = all.size();
		if(n > 0) {
			// find boundaries
			minX = all[0].x;
			minY = all[0].y;
			maxX = minX;
			maxY = minY;
			int n = all.size();
			for(int i = 0; i < n; i++) {
				if(all[i].x < minX)
					minX = all[i].x;
				if(all[i].y < minY)
					minY = all[i].y;
				if(all[i].x > maxX)
					maxX = all[i].x;
				if(all[i].y > maxY)
					maxY = all[i].y;
			}

			// center and square boundaries
			setMid();
			float diffX = maxX - minX;
			float diffY = maxY - minY;
			float halfSide = max(diffX, diffY) / 2;
			minX = midX - halfSide;
			maxX = midX + halfSide;
			minY = midY - halfSide;
			maxY = midY + halfSide;

			// add all the particles
			for(int i = 0; i < n; i++)
				add(all[i]);

			//draw();
		}
	}
	vector<Particle*> getNeighbors(float targetX, float targetY, float radius) {
		vector<Particle*> intersection, neighbors;
		getIntersection(intersection, targetX, targetY, radius);
		float xd, yd, rsq;
		float maxrsq = radius * radius;
		int n = intersection.size();
		for(int i = 0; i < n; i++) {
			Particle& cur = *intersection[i];
			xd = targetX - cur.x;
			yd = targetY - cur.y;
			rsq = xd * xd + yd * yd;
			if(rsq < maxrsq)
				neighbors.push_back(&cur);
		}
		return neighbors;
	}
	void getIntersection(vector<Particle*>& intersection, float targetX, float targetY, float radius) {
		if(targetX > minX - radius && targetX < maxX + radius &&
			targetY > minY - radius && targetY < maxY + radius) {
			if(nParticles) {
				for(int i = 0; i < nParticles; i++)
					intersection.push_back(particles[i]);
			} else if(hasChildren) {
				nw->getIntersection(intersection, targetX, targetY, radius);
				ne->getIntersection(intersection, targetX, targetY, radius);
				sw->getIntersection(intersection, targetX, targetY, radius);
				se->getIntersection(intersection, targetX, targetY, radius);
			}
		}
	}
	void addForce(float targetX, float targetY, float radius, float scale) {
		std::deque<Tree*> toProcess;
		toProcess.push_back(this);
		float xd, yd, length, effect;
		float sqradius = radius * radius;
		while(!toProcess.empty()) {
			Tree& curTree = *(toProcess.front());
			toProcess.pop_front();
			if(targetX > curTree.minX - radius && targetX < curTree.maxX + radius &&
				targetY > curTree.minY - radius && targetY < curTree.maxY + radius) {
				if(curTree.nParticles) {
					for(int i = 0; i < curTree.nParticles; i++) {
						Particle& curParticle = *(curTree.particles[i]);
						xd = curParticle.x - targetX;
						yd = curParticle.y - targetY;
						if(xd != 0 && yd != 0) {
							length = xd * xd + yd * yd;
							if(length < sqradius) {
								length = sqrtf(length);
								xd /= length;
								yd /= length;
								effect = 1 - (length / radius);
								effect *= scale;
								curParticle.xf += effect * xd;
								curParticle.yf += effect * yd;
							}
						}
					}
				} else if(curTree.hasChildren) {
					toProcess.push_back(curTree.nw);
					toProcess.push_back(curTree.ne);
					toProcess.push_back(curTree.sw);
					toProcess.push_back(curTree.se);
				}
			}
		}
	}
	void draw() {
		ofRect(minX, minY, maxX - minX, maxY - minY);
		if(hasChildren) {
			nw->draw();
			ne->draw();
			sw->draw();
			se->draw();
		}
	}
};
