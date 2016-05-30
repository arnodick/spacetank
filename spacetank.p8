pico-8 cartridge // http://www.pico-8.com
version 7
__lua__
--spacetank 9000
--by ashley pringle
cartdata("spacetank")

debug=false
debug_l={}

function _init()
	state=0
	timer=0
	changestate(state)
	--machinegun
	bullettype={}
	bullettype[1]={}
	bullettype[1].vel=6
	bullettype[1].rof=2
	bullettype[1].dest=true--{destroy/bounce,momentum}
	bullettype[1].num=1
	bullettype[1].acc=0.02
	bullettype[1].snd=3
	bullettype[1].rec=0.02
	bullettype[1].dam=1
	bullettype[1].proj=1
	bullettype[1].heat=5
	--shotgun
	bullettype[2]={}
	bullettype[2].vel=5
	bullettype[2].rof=10
	bullettype[2].dest=true--{destroy/bounce,momentum}
	bullettype[2].num=10
	bullettype[2].acc=0.05
	bullettype[2].snd=16
	bullettype[2].rec=0.1
	bullettype[2].dam=1
	bullettype[2].proj=1
	bullettype[2].heat=30
	--minigun
	bullettype[3]={}
	bullettype[3].vel=8
	bullettype[3].rof=1
	bullettype[3].dest=true--{destroy/bounce,momentum}
	bullettype[3].num=3
	bullettype[3].acc=0.045
	bullettype[3].snd=15
	bullettype[3].rec=0.03
	bullettype[3].dam=1
	bullettype[3].proj=1
	bullettype[3].heat=10
	--cannon
	bullettype[4]={}
	bullettype[4].vel=8
	bullettype[4].rof=8
	bullettype[4].dest=true--{destroy/bounce,momentum}
	bullettype[4].num=1
	bullettype[4].acc=0
	bullettype[4].snd=17
	bullettype[4].rec=0.06
	bullettype[4].dam=3
	bullettype[4].proj=2
	bullettype[4].heat=30
	--bouncy ball
	bullettype[5]={}
	bullettype[5].vel=4
	bullettype[5].rof=16
	bullettype[5].dest=false--{destroy/bounce,momentum}
	bullettype[5].num=1
	bullettype[5].acc=0
	bullettype[5].snd=24
	bullettype[5].rec=0
	bullettype[5].dam=3
	bullettype[5].proj=3
	bullettype[5].heat=60
		--light lazer
	bullettype[6]={}
	bullettype[6].vel=0
	bullettype[6].rof=2
	bullettype[6].dest=true--{destroy/bounce,momentum}
	bullettype[6].num=1
	bullettype[6].acc=0
	bullettype[6].snd=25
	bullettype[6].rec=0
	bullettype[6].dam=0.2
	bullettype[6].proj=4
	bullettype[6].heat=5
	--bouncy ballz tm
--	bullettype[7]={}
--	bullettype[7].vel=9
--	bullettype[7].rof=16
--	bullettype[7].dest=false--{destroy/bounce,momentum}
--	bullettype[7].num=10
--	bullettype[7].acc=0.08
--	bullettype[7].snd=24
--	bullettype[7].rec=0
--	bullettype[7].dam=3
--	bullettype[7].proj=3
--	bullettype[7].heat=60

	
	enums={}
	enums.tank=1
	enums.bullet=2
	enums.enemy=3
	enums.debris=4
	enums.explosion=5
	enums.cloud=6
	enums.crate=7
	enums.ufo=1
	enums.man=2
	enums.missile=3
	enums.intro=0
	enums.title=1
	enums.options=2
	enums.game=3
	
	hud={}
	hud.bar={}
	hud.bar.x=12
	hud.bar.y=10
	hud.bar.w=100
	hud.bar.h=6
	hud.bar.c=8
	hud.score={}
	hud.score.x=12
	hud.score.y=4
	hud.hp={}
	hud.hp.x=100
	hud.hp.y=4

	--groundheight=10
	--hillheight=60
	--groundwidth=3--how many low areas before go back to hill
	--hillwidth=3--how many hills before go back to ground
	hillspacing=50
	generatelandscape(10,30,3,3,hillspacing,true)
end

function generatelandscape(gh,hh,gw,hw,hs,first)
	level+=1
	local los,his=0,0
	local ys={}
	--ys[1],ys[2],ys[3]=0,0,0
	if not first then
		ys[1],ys[2],ys[3],ys[4],ys[5]=0,ground[197][2],ground[198][2],ground[199][2],ground[200][2]
	end
	ground={}
	ground[1]={0,0}
	--if not first then
	--	ground[1]={0,ys[1]}
	--end
	ground[1].ratio=1
	ground[1].d=0
	for a=2,200 do
		local h=0
		--h=groundheight
		h=gh
		if his>0 then
			--if his>hillwidth then 
			if his>hw then 
				his=0
				los+=1
			else
				his+=1
				--h+=hillheight
				h+=hh
			end
		--elseif los>groundwidth then
		elseif los>gw then
				los=0
				--h+=hillheight
				h+=hh
				his+=1
		else
				los+=1
		end
		--ground[a]={a*hillspacing,-flr(rnd(h))}
		ground[a]={a*hs,-flr(rnd(h))}
		if not first then
			if a>1 and a<6 then
				ground[a][2]=ys[a]
			end
		end
		local w=ground[a][1]-ground[a-1][1]
		local h=ground[a-1][2]-ground[a][2]
		ground[a-1].ratio=h/w
		ground[a-1].d=atan2(w,h)
	end
end

function distance(x1,y1,x2,y2)
	local a=(x2-x1)/10  local b=(y2-y1)/10
	--return sqrt((x2-x1)^2+(y2-y1)^2)
--	return sqrt(a*a+b*b)
	return (a*a+b*b)
end

function getgroundheight(x)
	local gx=flr(x/hillspacing)
	if gx>1 and gx<200 then
		if ground[gx][1]<x and ground[gx+1][1]>x then
			local w=x-ground[gx][1]
			return ground[gx][2]-w*ground[gx].ratio
		elseif ground[gx][1]==x then
			return ground[gx][2]
		end
	else
		return 0
	end
	return
end

function getgrounddir(a)
	for b=1,#ground-1 do
		if ground[b][1]<a.x and ground[b+1][1]>a.x then
			return ground[b].d
		end
	end
end

function makeactor(t,x,y,d,vel)
	local actor={}
	actor.t=t
	actor.x=x
	actor.y=y
	actor.d=d
	actor.vec={cos(d),sin(d)}
	actor.vel=vel
	actor.grav=true
	actor.delta=timer
	actor.accel=0.08
	actor.decel=0.02
	actor.maxvel=5

	add(actors,actor)
	return actor
end

function maketank(x,y,d,vel,bt)
	local tank=makeactor(1,x,y,d,vel)
	tank.bt=bt
	tank.hp=3
	tank.hit=0
	tank.drop=1
	makehitbox(tank,-4,-10,8,10)
	tank.gun={}
	tank.gun.angle=0.25
	tank.gun.len=6
	tank.gun.x=0
	tank.gun.y=0
	tank.gun.vec={0,0}
	tank.gun.delta=0
	tank.gun.heat=0
	
	tank.xoff=-3
	tank.yoff=-7
	return tank
end

function makebullet(x,y,d,vel,bt)
	local bullet=makeactor(2,x,y,d,vel)
	bullet.tail={0,0}
	bullet.bt=bt
	if bullet.bt==5 or bullet.bt==7 then
		bullet.decel=0
	elseif bullet.bt==6 then
		bullet.grav=false
		bullet.decel=0
	end
end

function makeenemy(x,y,d,vel,bt,et,hp)
	local enemy=makeactor(3,x,y,d,vel)
	enemy.et=et
	enemy.hp=hp
	if et==enums.ufo then
		enemy.grav=false
		makehitbox(enemy,1-8,2-4-4,12,9)
		enemy.drop=0.5
	elseif et==enums.man then
		makehitbox(enemy,0-4,0-4,8,8)
		enemy.deathsnd=18
		enemy.drop=0.1
	elseif et==enums.missile then
		enemy.grav=false
		makehitbox(enemy,0-4,0-4,5,8)
		enemy.drop=0.2
		counters.missiles+=1
	end
	counters.enemies+=1
end

function makedebris(x,y)
	local debris=makeactor(4,x,y,rnd(0.5),rnd(4)+3)
	debris.delta=timer
	debris.angle=rnd(1)
	debris.w=6
	debris.bounce=0
	return debris
end

function makeexplosion(x,y)
	local e=makeactor(5,x,y,0,0)
	e.grav=false
	e.delta=timer
	sfx(2)
	cam.shake=10
	for j=1,10 do
		makecloud(e.x+rnd(20)-10,e.y+rnd(20)-10,10)
	end
--	for k,v in pairs(actors) do
--		if distance(e.x,e.y,v.x,v.y)<5 then
--			if v.t==enums.enemy then
--				damageactor(v,3)
--			end
--		end
--	end
end

function makecloud(x,y,r)
	if x>cam[1] and x<cam[1]+128 then
	local e=makeactor(6,x,y,0,0)
	e.r=r
	e.grav=false
	e.delta=timer
	end
end

function makecrate(x,y,w,bt)
	local c=makedebris(x,y)
	c.t=7
	c.w=w
	c.bt=bt
	c.vel=rnd(4)+4
	c.d=rnd(0.15)
	c.decel=0.03
	makehitbox(c,-w/2-4,-w/2-4,w+6,w+6)
end

function makehitbox(a,x,y,w,h)
	a.hitbox={}
	a.hitbox.x=x
	a.hitbox.y=y
	a.hitbox.w=w
	a.hitbox.h=h
end

function drawactor(t)
	if t.t==enums.tank then
		spr(1,t.x+t.xoff,t.y+t.yoff)
		line(t.x+1,t.y-4+t.yoff+7,t.gun.x,t.gun.y+7,8)
	elseif t.t==enums.bullet then
		if bullettype[t.bt].proj==1 then
			line(t.x,t.y,t.tail[1],t.tail[2],7)
		elseif bullettype[t.bt].proj==2 then
			circfill(t.x,t.y,4,7)
			circfill(t.tail[1],t.tail[2],3,7)
--			circ(t.x,t.y,5,8)
		elseif bullettype[t.bt].proj==3 then
			--circ(t.tail[1],t.tail[2],6+(cos(timer/20))*2,7)
			--circ(t.tail[1],t.tail[2],3+(sin(timer/20))*2,7)
			circ(t.x,t.y,6+(cos(timer/20))*2,7)
			circ(t.x,t.y,3+(sin(timer/20))*2,7)
--			circ(t.x,t.y,5,8)
		elseif bullettype[t.bt].proj==4 then
			line(player.gun.x,player.gun.y-player.yoff,t.x,t.y,7)
		end
	elseif t.t==enums.enemy then
		if t.et==enums.ufo then
			spr(19+flr(cos(timer/20))*2,t.x-8,t.y-4,2,1)
		elseif t.et==enums.man then
			if player.hp!=0 then
				spr(33+(timer/20)%2,t.x-4,t.y-4,1,1,t.vel or false)
			else
				spr(35+(timer/20)%2,t.x,t.y,1,1,t.vel or false)
			end
		elseif t.et==enums.missile then
			spr(50,t.x-4,t.y-4,1,1)
		end
	elseif t.t==enums.debris then
		line(t.x-cos(t.angle)*t.w/2,t.y-sin(t.angle)*t.w/2,t.x+cos(t.angle)*t.w,t.y+sin(t.angle)*t.w,8)
	elseif t.t==enums.explosion then
		circfill(t.x,t.y,5+(timer-t.delta)*10,7)
	elseif t.t==enums.cloud then
		circfill(t.x,t.y,t.r-(timer-t.delta)*1,5)
	elseif t.t==enums.crate then
		drawbox(t.x,t.y,t.w,t.angle)
	end
	if debug then
		if t.hitbox!=nil then
			rect(t.x+t.hitbox.x,t.y+t.hitbox.y,t.x+t.hitbox.x+t.hitbox.w,t.y+t.hitbox.y+t.hitbox.h,12)
			pset(t.x,t.y,10)
		end
	end
end

function drawbox(x,y,w,a)
	line(x+cos(a     )*w/2,y+sin(a     )*w/2,x+cos(a+0.25)*w/2,y+sin(a+0.25)*w/2,7)
	line(x+cos(a+0.25)*w/2,y+sin(a+0.25)*w/2,x+cos(a+0.5 )*w/2,y+sin(a+0.5 )*w/2,7)
	line(x+cos(a+0.5 )*w/2,y+sin(a+0.5 )*w/2,x+cos(a+0.75)*w/2,y+sin(a+0.75)*w/2,7)
	line(x+cos(a+0.75)*w/2,y+sin(a+0.75)*w/2,x+cos(a     )*w/2,y+sin(a     )*w/2,7)
end

function collision(a,enemy)
	if  a.x>enemy.x+enemy.hitbox.x
	and a.x<enemy.x+enemy.hitbox.x+enemy.hitbox.w--+a.vec[1]*a.vel
	and a.y>enemy.y+enemy.hitbox.y---a.vec[2]*a.vel
	and a.y<enemy.y+enemy.hitbox.y+enemy.hitbox.h then
		return true
	else
		return false
	end
end

function controlactor(a)
	if a.t==enums.tank then
		if a.x>198*hillspacing then
			--if a==player then
			generatelandscape(20-rnd(5),40-rnd(20),3+rnd(6),3+rnd(12),hillspacing,false)
			--generatelandscape(20-rnd(15),100-rnd(95),3+rnd(3),3+rnd(3),hillspacing,false)
			--generatelandscape(20-rnd(15),150-rnd(145),3+rnd(5),3+rnd(5),hillspacing,false)
			--end
			for actor in all(actors) do 
				local diff=actor.x-198*hillspacing
				actor.x=hillspacing*3+diff
				if actor.x<=0 or actor.x>=hillspacing*200 then
					del(actors,actor)
				end
			end
			mothership.x=0
		end
		if btn(5) or btn(3) then
			a.vel-=a.decel*4
		else
			a.vel+=a.accel
		end
--			if btn(0) then 
--				a.vel-=a.accel
--			elseif btn(1) then 
--				a.vel+=a.accel
--			end
--		else
--			a.vel-=a.decel
--		end
		if btn(1) then
			a.gun.angle=clamp(a.gun.angle-0.016,0,0.5,true)
		elseif btn(0) then 
			a.gun.angle=clamp(a.gun.angle+0.016,0,0.5,true)
		end
		
		a.vel=clamp(a.vel,-a.maxvel,a.maxvel,true)
		
		a.gun.vec[1]=cos(a.gun.angle)
		a.gun.vec[2]=sin(a.gun.angle)
		a.gun.x=a.x+1+a.gun.vec[1]*a.gun.len
		a.gun.y=a.y-4+a.gun.vec[2]*a.gun.len
		
		if a.hit>0 then
			a.hit-=1
		end
--		sfx(8+abs(flr(a.vel)),0)
	elseif a.t==enums.bullet then
		a.tail={a.x-a.vec[1],a.y-a.vec[2]}
		if a.bt==4 then
			makecloud(a.x+rnd(10)-5,a.y+rnd(10)-5,3)
--		elseif a.bt==5 then
--			a.vel=4
		elseif a.bt==6 then
			if timer-a.delta>=2 then
				del(actors,a)
			end
		end
		for enemy in all(actors) do
			if enemy.t==enums.enemy then
				if collision(a,enemy) then
					damageactor(enemy,bullettype[a.bt].dam)
					if a.bt!=5 then
						del(actors,a)
					end
					makedebris(a.x,a.y)
				elseif a.bt==4 or a.bt==5 then
					if distance(a.x,a.y,enemy.x,enemy.y)<2 then
						damageactor(enemy,bullettype[a.bt].dam)
						if a.bt!=5 then
							del(actors,a)
						end
					makedebris(a.x,a.y)
					end
				end
				if bullettype[a.bt].proj==4 then
					local ld=atan2(enemy.x-player.gun.x,enemy.y-player.gun.y-player.yoff)
					if ld>player.gun.angle-0.02 and ld<player.gun.angle+0.02 then
						damageactor(enemy,bullettype[a.bt].dam)
					end
				end
			end
		end
	elseif a.t==enums.enemy then
		if a.et==enums.ufo then
			if a.x<=player.x+50 then
				a.maxvel=8
			else
				a.maxvel=4
			end
			if a.vel<=a.maxvel then
				a.vel+=a.accel
			else
				a.vel-=3
			end
			if counters.missiles==0 then
				if flr(a.x)==flr(player.x)+30 then
					sfx(20)
					makeenemy(a.x,a.y,0.9,4,1,3,1)
				end
			end
		elseif a.et==enums.man then
			a.vel=4
			if timer%2==0 then
				makecloud(a.x+1+rnd(4)-2,a.y+4+rnd(4)-2,2)
			end
		elseif a.et==enums.missile then
			--missile stuff
			a.vel=3
			if collision(a,player) then
				player.hit=20
				damageactor(player,1)
				damageactor(a,1)
			end
			if a.y>=getgroundheight(a.x) then
				damageactor(a,1)
			end
		end
	elseif a.t==enums.debris then
			a.angle+=0.1*a.vec[1]
			if timer-a.delta<=1 then
				a.bounce+=1
		end
		if a.bounce==4 then
			for j=1,4 do
				makecloud(a.x+rnd(20)-10,a.y+rnd(20)-10,6)
			end
			sfx(6)
			del(actors,a)
		end
	elseif a.t==enums.explosion then
		if timer-a.delta>=2 then
			for b=1,#actors do
				local t=actors[b]
				if t.t==enums.enemy then
					if distance(a.x,a.y,t.x,t.y)<5 then
						damageactor(t,2)
					end
				end
			end
			del(actors,a)
		end
	elseif a.t==enums.cloud then
		if timer-a.delta>=30 then
			del(actors,a)
		end
	elseif a.t==enums.crate then
		a.angle-=0.01*cos(a.d)*a.vel
		if timer-a.delta<=1 then
			a.bounce+=1
		end
		if collision(player,a) then
			sfx(14)
			counters.gets+=1
			for b=1,4 do
				makedebris(a.x,a.y)
			end
			while a.bt==player.bt do
				a.bt=flr(rnd(#bullettype))+1
			end
			player.bt=a.bt
			player.gun.heat=0
			player.gun.delta=0
			del(actors,a)
		end
	end

	if a.y<getgroundheight(a.x) then
		if a.grav then
			a.y+=gravity*(timer-a.delta)
			if a.t==enums.tank then
				a.yoff=-7
			end
		end
	else
		if a.t==enums.tank then
			a.yoff+=sin(timer/(12))
		end
		if a.t!=enums.cloud and a.t!=enums.explosion then
			a.delta=timer
		end
		if a.t!=enums.debris and a.t!=enums.crate then
			--make bounciness a variable!
			if a==player or (a.et!=2 and a.bt!=5) then
				a.d=getgrounddir(a)
			end
		end
		if a.t==enums.bullet then
			if a.x>cam[1] and a.x<cam[1]+128 then
				sfx(4)
			end
			--make an array of functions for this?
			--each function is indexed from array with the .bt value
			if bullettype[a.bt].dest then
				if bullettype[a.bt].proj==1 then
					makecloud(a.x+rnd(20)-10,a.y+rnd(20)-10,5)
				elseif bullettype[a.bt].proj==2 then
					makeexplosion(a.x,a.y)
				end
				del(actors,a)--delete for bounce!
			end
		end
		a.y=getgroundheight(a.x)+1
	end
	
	a.vec[1]=cos(a.d)
	a.vec[2]=sin(a.d)
	a.x+=a.vec[1]*a.vel
 a.y+=a.vec[2]*a.vel
 
 if a.vel<0 then
		a.vel+=a.decel
	elseif a.vel>0 then
		a.vel-=a.decel
	end

 
 if a.x<cam[1]-128
 or a.x>cam[1]+512
 or a.y>128
 or a.y<-512
 or a.x>=200*hillspacing
 or a.x<=1*hillspacing then
 	if a.t==enums.enemy then
 		counters.enemies-=1
 		if a.et==enums.missile then
 			counters.missiles-=1
 		end
 	end
 	if a.t!=enums.tank then
 		del(actors,a)
 	end
 end
 if a.t==enums.tank then
 	if a.gun.len<6 then
 		a.gun.len+=1
 	end
  a.gun.x=a.x+1+a.gun.vec[1]*a.gun.len
		a.gun.y=a.y-4+a.gun.vec[2]*a.gun.len+a.yoff
		if a.gun.delta==0 then
			hud.bar.c=8
			if btn(4) then
				sfx(bullettype[a.bt].snd)
				a.gun.len=2
				a.gun.heat+=bullettype[a.bt].heat
				if bullettype[a.bt].proj==4 then
				--laser
					makebullet(a.gun.x+a.gun.vec[1]*100,a.gun.y+a.gun.vec[2]*100,a.gun.angle,0,a.bt)
				else
					local bvel=sqrt( (a.gun.vec[1]*bullettype[a.bt].vel+a.vec[1]*a.vel)^2+(a.gun.vec[2]*bullettype[a.bt].vel+a.vec[2]*a.vel)^2 )
					for b=1,bullettype[a.bt].num do
						makebullet(a.gun.x,a.gun.y+7,a.gun.angle+rnd(bullettype[a.bt].acc)-bullettype[a.bt].acc/2,bvel+rnd(1)-1,a.bt)
					end
					if a.gun.angle<0.25 then
						a.gun.angle+=bullettype[a.bt].rec
					end
				end
				a.gun.delta=bullettype[a.bt].rof
			end
		else 
			a.gun.delta-=1
			if a.gun.delta>20 then
				if timer%3==0 then
					makecloud(a.gun.x,a.gun.y+6,4)
					hud.bar.c=7
				end
			end
		end
		if a.gun.heat>0 then
			if a.gun.heat>=100 then
				a.gun.heat=100
				a.gun.delta=100
				sfx(19)
			end
			a.gun.heat-=1
		else
			a.gun.heat=0
		end
		if cam.shake>0 then
			cam.shake-=1
		end
		cam[1]=a.x+8*player.vel+rnd(cam.shake)*2-56
		if a.y<-60 then
			cam[2]=-118+a.y+60
		else
			cam[2]=-118
		end
		if a.vel<1.5 then
			mothership.x+=0.8
			mothership.c=7
			mothership.spr=67
		elseif a.vel<3.5 then
			mothership.x+=player.vel+0.1
			mothership.c=7
			mothership.spr=67
		end
		if mothership.x>a.x then
			if a.hp>0 then
				damageactor(a,3)
			end
		elseif mothership.x<cam[1]-1 then
			mothership.x=cam[1]-1
			mothership.c=0
			mothership.spr=110
		else
			sfx(38)
		end
 end
end

function damageactor(a,d)
	if a.t==enums.tank then
		sfx(21)
	else
		sfx(5)--todo: just implement a damage noise for each actor
	end
	pal(8,7)
	a.hp-=d or 3
	if a.hp<1 then
		pause=2
		if a.et==enums.ufo then
			for b=1,6 do
				makedebris(a.x,a.y)
			end
		elseif a.et==enums.missile then
			counters.missiles-=1
			if	counters.missiles<0 then
				counters.missiles=0
			end
		elseif a.t==enums.tank then
			sfx(23)
		end
		sfx(a.deathsnd)
		makeexplosion(a.x,a.y)
		if rnd(1)<a.drop+1/(level*2) then
			makecrate(a.x,a.y,12,flr(rnd(#bullettype))+1)
		end
		del(actors,a)
		counters.enemies-=1
	end
end

function spawnentities()
	if counters.enemies<level then
		if spawntimer<10 then
			spawntimer+=1
		else
			if rnd(1)<0.3 then
				--spawn man
				if player.hp!=0 then
					--makeenemy(cam[1]+130,-rnd(128),0.15,3,6,2,1)
					makeenemy(cam[1]+130,getgroundheight(cam[1]+130)-rnd(10),0.15,3,6,2,1)
				else
					makeenemy(cam[1]-12,-rnd(128),0.15,3,6,2,1)
				end
			elseif rnd(1)<0.3 then
				--spawn ufo
				makeenemy(cam[1]-12,-100+rnd(40),0,5,6,1,3)
			end
			spawntimer=0
		end
	end
end

function _update()
	if state==enums.intro then
		if btnp(4) or timer>=1140 then
			sfx(2)
			changestate(enums.title)
		end
	elseif state==enums.title then
		--title menu logic here!
		if btnp(4) then
			makeexplosion(60,60)
			titletimer=20
		elseif btnp(5) then
			changestate(enums.options)
		end
		if titletimer>1 then
			titletimer-=1
		elseif titletimer==1 then
			changestate(enums.game)
		end
	elseif state==enums.options then
		if btnp(4) or btnp(5) then
			changestate(enums.title)
		end
	elseif state==enums.game then
		if pause==0 then
			foreach(actors,controlactor)
			if player.hp<=0 then
				mothership.x-=0.5
			end
			spawnentities()
		else
			pause-=1
		end
		if player.hp<=0 then
			if counters.gets>dget(0) then
				dset(0,counters.gets)
			end
			deathtimer+=1
			if deathtimer>60 then
				if btnp(4) then
					changestate(enums.game)
				end
			end
		end
		debug_u()
	end
	timer+=1
end

function _draw()
	cls()
	camera(cam[1],cam[2])
	if state==enums.intro then
		--drawintro(0,120,255,{16,16,10,30},{1,6,10,10})
		drawintro(0,120,255,{16,40,50,60},{1,2,2,2})
	elseif state==enums.title then
		spr(128,0,0,4,4)
		spr(132,28,0,4,4)
		spr(136,52,0,4,4)
		spr(140,78,0,4,4)
		spr(192,104,0,4,4)
		spr(196,10,32,4,4)
		spr(136,38,32,4,4)
		spr(200,64,32,4,4)
		spr(204,92,32,4,4)
		print("9000",53,68,8)
		print("start: button 1",34,90,8)
		print("instructions: button 2",20,100,8)
		print("hi score: "..dget(0),41,120,8)
		foreach(actors,drawactor)
	elseif state==enums.options then
		pal(7,flr(rnd(15))+1)
		print("instructions:",40,10,8)
		spr(19+flr(cos(timer/20))*2,0,22,2,1)
		spr(33+(timer/20)%2,3,32,1,1)
		print("the aliens possess powerful\nweapon technology which\nmutates the geneology of\nweapons",20,20,8)
		print("they can't be trusted with\nsuch powerful arms\ndestroy them and salvage\ntheir tech to mutate\nspacetank's weapon so\nit can be used for good",20,50,8)
		drawbox(7,66,12,-timer/100)
		spr(1,2,94+sin(timer/(12)),1,1)
		line(5,98+sin(timer/(12)),10,94+sin(timer/(12)),8)
		print("shoots = button 1\ngun angle = dpad left/right\nbrake = button 2 or down",20,90,8)
	elseif state==enums.game then
		pal(7,flr(rnd(15))+1)
		if player.hit>0 then
			pal(8,flr(rnd(15))+1)
		end
		if timer<30 then
			sspr(8,32,16,16,135,-230,32,32)
		end
		for a=1,#ground-1 do
			line(ground[a][1],ground[a][2],ground[a+1][1],ground[a+1][2],8)
			line(ground[a][1]+8,ground[a][2]+8,ground[a+1][1]+8,ground[a+1][2]+8,7)
		end
		spr(24,300,getgroundheight(300)-23,7,3)
		print(level,312,getgroundheight(300)-5,7)
		if mothership.x>cam[1] then
			--rectfill(mothership.x-10,mothership.y-108,mothership.x-1,mothership.y,mothership.c)
			--spr(mothership.spr,mothership.x-12,mothership.y-120,2,2)
			--rectfill(mothership.x-10,cam[2]+12,mothership.x-1,mothership.y,mothership.c)
			rectfill(mothership.x-10,cam[2]+12,mothership.x-1,getgroundheight(mothership.x),mothership.c)
			circfill(mothership.x-5.5,getgroundheight(mothership.x),4.95,mothership.c)
			spr(mothership.spr,mothership.x-12,cam[2],2,2)
		end
		foreach(actors,drawactor)
	--	drawactor(player)--so that tank is drawn over other stuff like bullets
		if player.gun.heat>0 then
			rectfill(cam[1]+hud.bar.x,cam[2]+hud.bar.y,cam[1]+hud.bar.x+player.gun.heat,cam[2]+hud.bar.y+hud.bar.h,hud.bar.c)
			rect(cam[1]+hud.bar.x,cam[2]+hud.bar.y,cam[1]+hud.bar.x+hud.bar.w,cam[2]+hud.bar.y+hud.bar.h,8)
		end
		print("crates:"..counters.gets,cam[1]+hud.score.x,cam[2]+hud.score.y,8)
		print("hp:"..player.hp,cam[1]+hud.hp.x,cam[2]+hud.hp.y,8)
		if debug then
			for a=1,#debug_l do
				print(debug_l[a],cam[1]+0,cam[2]+(a-1)*6,11)
			end
		end
		if player.hp<=0 then
			print("space tank died",cam[1]+34,cam[2]+50,8)
			print("in the year 9000",cam[1]+32,cam[2]+60,8)
			--print("at mine "..level,cam[1]+44,cam[2]+70,8)
			print("with "..counters.gets.." weapon crates",cam[1]+24,cam[2]+70,8)
			if deathtimer>60 then
				if timer%40<=20 then
					print("restart: button 1",cam[1]+30,cam[2]+80,8)
				end
			end
		end
		pal()
	end
end

function drawintro(x,y,st,td,col)
	local ind=0
	for a=0,2 do
		if timer>st*2^a then ind=a+1 end
	end
	for a=1,#introtext do
		--print(introtext[a],x,y+a*7-timer/4,8)
		print(introtext[a],x,y+a*7-timer/4,7+((timer+(a-1)*10)/td[ind+1])%col[ind+1])
	end
end

function clamp(v,mi,ma,h)
	if h then
		if v<mi then v=mi
		elseif v>ma then v=ma
		end
	else
		if v<mi then v=ma
		elseif v>ma then v=mi
		end
	end
	return v
end

function changestate(s)
	state=s
	timer=0
	spawntimer=0
	level=1
	cam={0,0}
	actors={}
	introtext={}
	titletimer=0
	music(-1)
	if state==0 then
		music(0)
		add(introtext,"it is the year 9000")
		add(introtext,"")
		add(introtext,"humanity has expanded its empire")
		add(introtext,"to the outer reaches of the")
		add(introtext,"universe")
		add(introtext,"")
		add(introtext,"we have finally reached planet x")
		add(introtext,"fabled home world of the")
		add(introtext,"invaluable 'space ore'")
		add(introtext,"")
		add(introtext,"humanity's mining operations")
		add(introtext,"have been wildly successful")
		add(introtext,"the precious space ore has")
		add(introtext,"brought prosperity and peace")
		add(introtext,"to humanity, but....")
		add(introtext,"")
		add(introtext,"the evil x-onians are disrupting")
		add(introtext,"our mining operations")
		add(introtext,"they destroy our mines and")
		add(introtext,"steal our hard earned ore")
		add(introtext,"")
		add(introtext,"without the valuable space ore")
		add(introtext,"humanity's economy will collapse")
		add(introtext,"and chaos will ensue")
		add(introtext,"")
		add(introtext,"there is only one way")
		add(introtext,"for us to stop them")
		add(introtext,"")
		add(introtext,"you have the technology")
		add(introtext,"you are powerful and good")
		add(introtext,"you are..........")
	elseif state==3 then
		pause=0
		cam={0,0}
		cam.shake=0
		counters={}
		counters.enemies=0
		counters.gets=0
		counters.missiles=0
		gravity=0.2
		deathtimer=0
		sfx(37)
		player=maketank(150,-200,0,0,1)
		mothership={}
		mothership.x=120
		mothership.y=getgroundheight(mothership.x)
		mothership.c=7
		mothership.spr=67
	end
end

function debug_u()
	debug_l[1]=timer
	debug_l[2]="mem="..stat(0)
	debug_l[3]="cpu="..stat(1)
	debug_l[4]="actors:"..#actors
	debug_l[5]="tank x:"..player.x
	debug_l[6]="tank y:"..player.y
	debug_l[7]="tank vel:"..player.vel
	debug_l[8]="gun x:"..player.gun.x
	debug_l[9]="gun y:"..player.gun.y
	debug_l[10]="gun d:"..player.gun.angle
	debug_l[11]="gun vx:"..player.gun.vec[1]
	debug_l[12]="gun vy:"..player.gun.vec[2]	
	debug_l[13]="ratio:"..getgroundheight(player.x)
	debug_l[14]="tank vx:"..player.vec[1]
	debug_l[15]="tank vy:"..player.vec[2]
	debug_l[16]="enemy cnt:"..counters.enemies
	debug_l[17]="missiles cnt:"..counters.missiles
	debug_l[18]="camx:"..cam[1]
	debug_l[19]="camy:"..cam[2]
	debug_l[20]="heat:"..player.gun.heat
--	debug_l[21]="dist:"..distance(player.x,player.y,160,-5)
	debug_l[21]="spawnt:"..spawntimer
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000888888888000000088888888800000008888888880000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008000000000800000800000000080000080000000008000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080008080808080008008080808008000808080808000800000000000000000000000000000000000000000000000000000000000000000000000000
00000000008000000000800000800000000080000080000000008000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000888888888000000088888888800000008888888880000000000000000000000000055555550000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000550000055000000000000000000000000000000000000000000
00000000000000000008880000000000000880000000000000000000000000000000000000005000000000500000000000000000000000000000000000000000
00000000000888000000000000088000000000000000000000000000000000000000000000050000000005050000000000000000000000000000000000000000
00000000000000000008080800000000080880800000000000000000000000000000000000500000000050050000000000000000000000000000000000000000
00000000000808080880880800088000008008000000000000000000000000000000000000005555000500050500000000000000000000000000000000000000
00000000088088080000000008800880000880000000000000000000000000000000000005550000550000005005000000000000000000000000000000000000
00000000000000000008080000088000088008800000000000000000000000000000000050000000005000050050500000000000000000000000000000000000
00000000000808000008008000800800000000000000000000000000000000000000000050000000005000500500500000000000000000000000000000000000
00000000000808000000000000800800000000000000000000000000000000000000000050000000005000005000500000000000000000000000000000000000
00000000000000000007000000000000000000000000000000000000000000000000005050000000005050050050500000000000000000000000000000000000
00000000888888800077700000000000000000000000000000000000000000000000050500000000000505000550000000000000000000000000000000000000
00000000800080080807080000000000000000000000000000000000000000000000050000000000000005005050000000000000000000000000000000000000
00000000800008080080800000000000000000000000000000000000000000000000050000000000000005005000000000000000000000000000000000000000
00000000888888800080800000000000000000000000000000000000000000000000050000000000000005005000000000000000000000000000000000000000
00000000000000000080800000000000000000000000000000000000000000000000050000000000000005000000000000000000000000000000000000000000
00000000808008080008000000000000000000000000000000000000000000000000050000000000000005000000000000000000000000000000000000000000
00000000080000800008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008000000000000000000080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008800000000000000080080800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008080000000000008008080808008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008008000000000000808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888888880000000088888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000800000000808000080880000000880800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000800000000800800008800808080088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000800800080088080088000000000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000800800800000008088080808080808800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088808888888888808800000000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000880000000000080880808080880800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000800000000000000088888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000800800080080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000008000888880008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888888888888888888888800000000008888888888888888880000000000000088888888888888888888000000000000888888888888888888880000000000
08888888888888888888888880000000088888888888888888888000000000000888888888888888888888800000000008888888888888888888888000000000
88888888888888888888888888000000888888888888888888888800000000008888888888888888888888880000000088888888888888888888888800000000
88888888888888888888888888000000888888888888888888888800000000008888888888888888888888880000000088888888888888888888888800000000
88888888888888888888888888000000888888888888888888888800000000008888888888888888888888880000000088888888888888888888888800000000
88888888888888888888888888000000888888888888888888888800000000008888888888888888888888880000000088888888888888888888888800000000
88888880000000000000000000000000888888800000000088888800000000008888888000000000008888880000000088888880000000000000000000000000
88888880000000000000000000000000888888800000000088888800000000008888888000000000008888880000000088888880000000000000000000000000
88888880000000000000000000000000888888800000000088888800000000008888888000000000008888880000000088888880000000000000000000000000
88888880000000000000000000000000888888800000000088888800000000008888888000000000008888880000000088888880000000000000000000000000
88888888888888888888888000000000888888888888888888888800000000008888888888888888888888880000000088888880000000000000000000000000
88888888888888888888888800000000888888888888888888888800000000008888888888888888888888880000000088888880000000000000000000000000
88888888888888888888888880000000888888888888888888888800000000008888888888888888888888880000000088888880000000000000000000000000
08888888888888888888888888000000888888888888888888888000000000008888888888888888888888880000000088888880000000000000000000000000
00888888888888888888888888000000888888888888888888880000000000008888888888888888888888880000000088888880000000000000000000000000
00000000000000000000888888000000888888800000000000000000000000008888888000000000008888880000000088888880000000000000000000000000
00000000000000000000888888000000888888800000000000000000000000008888888000000000008888880000000088888880000000000000000000000000
00000000000000000000888888000000888888800000000000000000000000008888888000000000008888880000000088888880000000000000000000000000
00000000000000000000888888000000888888800000000000000000000000008888888000000000008888880000000088888880000000000000000000000000
00000000000000000000888888000000888888800000000000000000000000008888888000000000008888880000000088888880000000000000000000000000
88888888888888888888888888000000888888800000000000000000000000008888888000000000008888880000000088888888888888888888888800000000
88888888888888888888888888000000888888800000000000000000000000008888888000000000008888880000000088888888888888888888888800000000
88888888888888888888888888000000888888800000000000000000000000008888888000000000008888880000000088888888888888888888888800000000
88888888888888888888888888000000888888800000000000000000000000008888888000000000008888880000000088888888888888888888888800000000
08888888888888888888888880000000888888800000000000000000000000008888888000000000008888880000000008888888888888888888888000000000
00888888888888888888888800000000888888800000000000000000000000008888888000000000008888880000000000888888888888888888880000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888888888888888888888800000000008888888888888888888888000000000088000000000000000088888800000000888000000000008888000000000000
08888888888888888888888880000000088888888888888888888888800000000888800000000000000088888800000008888800000000088888800000000000
88888888888888888888888888000000888888888888888888888888880000008888880000000000000088888800000088888880000000888888880000000000
88888888888888888888888888000000888888888888888888888888880000008888888000000000000088888800000088888880000008888888800000000000
88888888888888888888888888000000888888888888888888888888880000008888888800000000000088888800000088888880000088888888000000000000
88888888888888888888888888000000888888888888888888888888880000008888888880000000000088888800000088888880000888888880000000000000
88888880000000000000000000000000000000000088888800000000000000008888888888000000000088888800000088888880008888888800000000000000
88888880000000000000000000000000000000000088888800000000000000008888888888800000000088888800000088888880088888888000000000000000
88888880000000000000000000000000000000000088888800000000000000008888888888880000000088888800000088888880888888880000000000000000
88888880000000000000000000000000000000000088888800000000000000008888888888888000000088888800000088888888888888800000000000000000
88888888888888888880000000000000000000000088888800000000000000008888888888888800000088888800000088888888888888000000000000000000
88888888888888888880000000000000000000000088888800000000000000008888888888888880000088888800000088888888888880000000000000000000
88888888888888888880000000000000000000000088888800000000000000008888888088888888000088888800000088888888888800000000000000000000
88888888888888888880000000000000000000000088888800000000000000008888888008888888800088888800000088888888888800000000000000000000
88888888888888888880000000000000000000000088888800000000000000008888888000888888880088888800000088888888888880000000000000000000
88888888888888888880000000000000000000000088888800000000000000008888888000088888888088888800000088888888888888000000000000000000
88888880000000000000000000000000000000000088888800000000000000008888888000008888888888888800000088888888888888800000000000000000
88888880000000000000000000000000000000000088888800000000000000008888888000000888888888888800000088888880888888880000000000000000
88888880000000000000000000000000000000000088888800000000000000008888888000000088888888888800000088888880088888888000000000000000
88888880000000000000000000000000000000000088888800000000000000008888888000000008888888888800000088888880008888888800000000000000
88888888888888888888888888000000000000000088888800000000000000008888888000000000888888888800000088888880000888888880000000000000
88888888888888888888888888000000000000000088888800000000000000008888888000000000088888888800000088888880000088888888000000000000
88888888888888888888888888000000000000000088888800000000000000008888888000000000008888888800000088888880000008888888800000000000
88888888888888888888888888000000000000000088888800000000000000008888888000000000000888888800000088888880000000888888880000000000
08888888888888888888888880000000000000000088888800000000000000008888888000000000000088888000000008888800000000088888800000000000
00888888888888888888888800000000000000000088888800000000000000008888888000000000000008880000000000888000000000008888000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000e07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002866019650106500b65008640056400464003630026300163001630016200162001610016100161001610016100161001610016100161000000000000000000000000000000000000000000000000000
000300003067002610186600266008650056500465003640026400163001630016200162001610016100161001610016100161001610016100160000000000000000000000000000000000000000000000000000
00030000166500f640036300162001610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001c6300e620066100060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200001c64000000357503574035750357403575035740357503574035730357203570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002661003610026100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000172001600016100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000a7400a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a700
000100000a7200a7300a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a700
000100000a7100a7200a7100a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a700
000100000a7100a7100a7100a7100a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a700
000100000a7100a7100a7100a7100a7100a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a700
000100000a7100a7200a7100a7200a7100a7200a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a7000a700
000400000c640146002e6302e6401a0001a5401a5301a5401a5301a0001a530006001a50000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200000644002050066400205006440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000b670026100b660086600a6500b6500d6500e640106401163012630136201362014610146101561015610146100f61008610066100160000000000000000000000000000000000000000000000000000
0002000003670027700267002770046700566028660296502a6502963025630246301f6301b6301762014620116200e6100c6100b6100b6100b6100b610096100761005610056100000000000000000000000000
000300002613025130271302c1302b1302c130291302413018130121300d130031300113001100011000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000400001527010640112700c6400f2700d2500a6400c27009650086400a270082500464005270026400227002640016400160002600016000160000000000000000000000000000000000000000000000000000
000300003d7403b740387403674034740317402e7402c7402a7402874025740227401f7401d7401c740197401774013740117400e7400c7400974008740067400574003740000000000000000000000000000000
000500002844028040284402804028440280402844028040284402804028440280402844000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002437024370243702437021370213702137021370003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
001400001e5401e5401e5401e5401e5401d5401d5401d5401d5401d5401c5401c5401c5401c5401c5401b5401b5401b5401b5401b540195401a540195401a540195401a540195401a54019540195401954019540
00030000040700507006070080700b070110701b07025070230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000d2400d2300d2400d2300d2000d2000d20000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000800000a4400a4400a4000a4000a4400a4400d4400d440144000f4000f4400f4401e2000b4000a4400a4401d2001d2000d4400d4400f4400f44000000000000a4400a44000000000000d4400d4400d40000000
000800000a4400a4400a4000a4000a4400a4400d4400d440144000f4000f4400f4401e2000b4000a4400a4401d2001d2000d4400d4400f4400f44000000000000b4400b4400b4400b4400b4400b4400000000000
000800000a4400a4400a4000a4000a4400a4400d4400d440144000f4000f4400f4401e2000b4000a4400a4000a4400a4000f4400f4400d4400d4400c4000c400104401044010440104400f4400f4400f4000f400
000800001653016530165301653016530165301653016530165301653016530165301653016530165301653016530165301653016530165301653016530165301653016530165301653016530165301653016530
000800001653016530165301653016530165301653016530165301653016530165301653016530165301653016530165301653016530165301653016530165301753017530175301753017530175301753017530
000800001653016530165301653016530165301653016530165301653016530165301653016530165301653016530165301953019530175301753017530175301653016530165301653017530175301753017530
0008000005300056000000008700053000a600086000860008700087000a3000870008700087000a340000000a340087000b640000000a3400000008340000000634006300086000a2000b440000000000000000
00080000033400560000000087000334005600086400860008700087000a340087000870008700086400000000000087000a340000000000000000086400000000000086000a3400000008640000000000000000
0008000003340056000000008700033400a600086400860008700087000a3400870008700087000a340000000a340087000b640000000a3400000008340000000634006300086000a2000b440000000000000000
000f00001952019520195201952019520195201952019520195201952019520195201952019520195201952017520175201752017520175201752017520175201652016520165201652016520165201652016520
000f00001c3201c3201c3201c3201c3201c3201c3201c3201c3201c3201c3201c3201c3201c3201c3201c3201b3201b3201b3201b3201b3201b3201b3201b3201932019320193201932019320193201932019320
000600003f0403d0403d0403c0403b0403a0403a0403904039040380403804037040370303604035040340403404033040320403104030040300402f0402e0402d0402c0402a0402704007440074400744007440
000200000223002230012000120001200012000120001200012000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 1a424344
00 1b424344
00 1a424344
00 1c424344
00 1a1d4344
00 1b1e4344
00 1a1d4344
00 1c1f2044
00 1a1d2144
00 1b1e2144
00 1a1d2144
00 1c1f2244
00 1a1d2144
00 1b1e2144
00 1a1d2144
00 1c1f2244
02 49232444
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

