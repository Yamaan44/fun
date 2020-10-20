clear

%% inputs
N = 6;
g=9.81;
tf=10;
%lvec = rand(N,1);
lvec = [5 6 7 8 7 6];
%mvec = rand(N,1);
mvec = [2 2 2 2 2 2];
inits = pi/6 *[1 1 1 1 1 1 0 0 0.00 0.00 0.00 0.00]';
%inits = 60*[0.05 0.05 0.01 0.01]';
%inits = [0.05 0.01];

%% initialize symbolic variables
syms t
TH = sym('th', [1 N],'real');
THD = sym('thd', [1 N],'real');
THDD = sym('thdd', [1 N],'real');
THrep = sym('th', [1 N],'real');
THDrep = sym('thd', [1 N],'real');
THDDrep = sym('thdd', [1 N],'real');


Str1 = [];
Str2 = Str1;
Str3 = Str2;
for j = 1:N
    Str1 = [Str1 ' th' num2str(j) '(t)'];
    Str2 = [Str2 ' thd' num2str(j) '(t)'];
    Str3 = [Str3 ' thdd' num2str(j) '(t)'];
end

eval(['syms ' Str1 ]);
eval(['TH= [' Str1 ']']);
eval(['syms ' Str2 ]);
eval(['THD= [' Str2 ']']);
eval(['syms ' Str3]);
eval(['THDD= [' Str3 ']']);



%% Lagrangian

%Calculate T for system
T=0;
for i = 1:N
    vi_temp = velocitysym(i,lvec,TH,THD);
    T = T + mvec(i)*(vi_temp(1)^2 + vi_temp(2)^2);
    
end
T= T/2; 

%Calculate V for system
V = 0;
for i = 1:N
   r_temp=positionsym(i,lvec,TH);
   V = V + mvec(i)*r_temp(2); 
end
V = V*g;

%Lagrangian
L = T-V;

%% Find EoM

B = diff(L,TH(1));
A = diff(L,THD(1));

eq=sym(zeros(1,N));
EQ=sym(zeros(1,N));

% build ith equation of motion 
for i = 1:N
    B = diff(L,TH(i));
    A = diff(L,THD(i));
    %C = subs(A,THD,diff(THD,t));
    %now need to time differentiate A
    C = diff(A,t);
    C = subs(C,diff(TH,t),THD);
    C = subs(C,diff(THD,t),THDD);
    
    eq(i)=C-B;
    EQ(i) = eq(i) == 0;
    
    
end

%% 
%replace time dependent variables with normal
EQ=subs(EQ, [TH THD THDD], [THrep THDrep THDDrep]);
ODEs=solve(EQ, THDDrep);

odefunc = cell(N,1);
%%
if N > 1
    for i = 1:N
        odefunc{i}=eval(['matlabFunction(ODEs.thdd' num2str(i) ')']);
    end
else
    odefunc{1} = ODEs;
end


%% Simulate
tspan = linspace(0,tf,1000);
[Tout,Yout]=ode45(@(t,z) pendulum(t,z,odefunc),tspan,inits);
%% plot it
figure()
for j = 1:length(Tout) 
    for k = 1:N
       ri = positionsym(k,lvec,Yout(j,1:N));
       rix = ri(1);
       riy = ri(2);
       plot(rix,riy,'o');
       hold on
       plot([(rix - lvec(k)*sin(Yout(j,k))/2) (rix + lvec(k)*sin(Yout(j,k))/2)],[(riy + lvec(k)*cos(Yout(j,k))/2) (riy - lvec(k)*cos(Yout(j,k))/2)],'r')
       
    end
    hold off
    xlim([-sum(lvec)-5 sum(lvec)+5])
    ylim([-sum(lvec)-5 5])
    drawnow 
end

%% functions
function dz = pendulum(~,z,odefunc)
    N = length(z)/2;
    dz = zeros(2*N,1);
    dz(1:N) = z(N+1:end);
    if N > 1
        for i = 1:N
            %unpack each function
            tempfunc=odefunc{i};
            zprime = num2cell(z);
            dz(N+i)=tempfunc(zprime{:});
        end
    else
        tempfunc=odefunc{1};
        tempfunc=matlabFunction(tempfunc);
        zprime = num2cell(z);
        dz(2) = tempfunc(zprime{1});
    end
end

function ri = positionsym(N,lvec,TH) %this function calculates the COM position of the Nth link
    rix_temp = 0;
    riy_temp = 0;
    for i = 1:N-1
        rix_temp = rix_temp + lvec(i)*sin(TH(i));
        riy_temp = riy_temp - lvec(i)*cos(TH(i));
    end
    rix = rix_temp + 0.5*lvec(N)*sin(TH(N));
    riy = riy_temp - 0.5*lvec(N)*cos(TH(N));
    
    ri = [rix; riy];
end



function vi = velocitysym(i,lvec,TH,THD) %function takes in index i and gives you velocity components of ith link COM 
    if i == 1
        vix = 0.5*lvec(1)*THD(1)*cos(TH(1));
        viy = 0.5*lvec(1)*THD(1)*sin(TH(1));
        vi=[vix; viy];
    else
        vix_temp = 0.5*lvec(i)*THD(i)*cos(TH(i));
        viy_temp = 0.5*lvec(i)*THD(i)*sin(TH(i));
        vi_temp=[vix_temp; viy_temp];
        vi = vi_temp + velocitysym(i-1,lvec,TH,THD);
    end
end