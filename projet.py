import numpy as np
from collections import Counter
import random


def absolute_distance(x1, x2, y1, y2, size): # Calcule la meilleure distance globale sur les deux axes (x, y) sur le Grid entre deux points
    return [x2 - x1, y2 - y1]
    if abs((x1-x2))<abs((size-x1+x2)):
            dx = x2 - x1
    else:
        dx = size-x1+x2
    if abs((y1-y2))<abs((size-y1+y2)):
        dy = y2 - y1
    else:
        dy = size-y1+y2
    return [dx, dy]
    

def dist_from_center(state, radius): # A partir de la perception d'un agent récupére la distance sur les  axes (x, y) vers la proie la plus proche
    r = np.where(np.array(state) > 1)
    if len(r[0])>1:
        lis = []
        real_lis = []
        for j in r:    
            x_prey = j[0] - radius
            y_prey = j[1] - radius
            lis.append(abs(x_prey)+abs(y_prey))
            real_lis.append([x_prey, y_prey])
        best = min(lis)
        best_value = real_lis[lis.index(best)]
        return best_value
    elif len(r[0])==1:
        x_prey = r[0][0] - radius
        y_prey = r[1][0] - radius 
        return [x_prey, y_prey]
    else:
        return [0]

def mean_tables(tables): # Fonction permettant de moyenner les Q-Tables
    all_keys = []
    results  = {}
    for i in tables:
        all_keys += i.keys()
    all_keys = list(set(all_keys))
    for i in all_keys:
        results[i] = {}
        for j in ["up", "down", "left", "right", "stay"]:
            summ = 0
            nbr = 0
            for k in tables:
                if i in k.keys() and k[i][j]!=0:
                    summ += k[i][j]
                    nbr += 1
            if nbr != 0:
                summ /= nbr
            results[i][j] = summ
            
    return results
    
class Agent: # Class d'agent récupérant l'ensemble des paramètres définis sur Netlogo
    def __init__(self, posx, posy, state_size, action_size, beta, gamma, typer, grid_width, grid_length ,intelligent=False, world_wraps=False, epsilon=0, decay_rate=0, save=False):
        self.Q = {}
        self.world_wraps = world_wraps
        self.posx = posx
        self.posy = posy
        self.type = typer
        self.grid_width = grid_width
        self.grid_length = grid_length
        self.intelligent = intelligent
        self.steps = 0
        if self.intelligent:
            self.beta = beta
            self.gamma = gamma
            self.epsilon = epsilon
            self.decay_rate = decay_rate
            
            self.actions_history = []
            self.rewards_history = []
            self.states_history = []
            self.new_states_history = []
            self.save = save
            
    def pprint(self):
        if self.type=="dead": return ""
        ret = ""
        ret += "Type = "+str(self.type)+" / Intelligent = "+str(self.intelligent)+"\n"
        ret += "( X="+str(self.posx)+" / Y="+str(self.posy)+" )"+"\n"
        ret += str(self.steps)+" steps."
        if self.intelligent:
            ret += "Beta = "+str(self.beta)+" / Gamma  = "+str(self.gamma)+" / Decay Rate = "+str(self.decay_rate)+"\n"
            ret += "History size = "+str(len(self.actions_history))+"\n"
        ret += "\n"
        return ret

    def choose(self, state=None): # Mouvement d'un agent
        if self.type=="dead": return
        if self.type=="expert": # Si l'agent est  un expert un algorithme lui est dedié
            if state==0:
                return random.choice(["up", "down", "left", "right", "stay"])
            if state[0]<0:
                return "left"
            elif state[0]>0:
                return "right"
            elif state[1]>0:
                return "up"
            elif state[1]<0:
                return "down"
            else:
                return "stay"
        self.steps += 1
        if not self.intelligent: # Si  l'agent n'est pas intelligent ( proie ) effectuer un mouvement aléatoire
            direction = random.choice(["up", "down", "left", "right", "stay"])
            return direction
        if random.uniform(0, 1) < self.epsilon:  # Si le jet est inferieur à epsilon  on effectue  de l'Exploration
            direction = random.choice(["up", "down", "left", "right", "stay"])
        else:      # Sinon on prend l'action ayant la meilleure Q-Value
            if str(state) in self.Q:
                direction = np.random.choice([key for key in self.Q[str(state)].keys() if self.Q[str(state)][key]==max(self.Q[str(state)].values())])
            else:
                self.Q[str(state)] = {}
                self.Q[str(state)]['up'] = 0
                self.Q[str(state)]['down'] = 0
                self.Q[str(state)]['left'] = 0
                self.Q[str(state)]['right'] = 0
                self.Q[str(state)]['stay'] = 0
                direction = np.random.choice([key for key in self.Q[str(state)].keys() if self.Q[str(state)][key]==max(self.Q[str(state)].values())])
        return direction
    
    def place(self, x, y): # Place l'agent à une certaine position
        if self.type=="dead": return
        self.posx = x
        self.posy = y
        if self.intelligent:
            self.epsilon -= self.decay_rate
        self.steps = 0
        
    def optimal_value(self, state): # Récupére la meilleure Q-Value d'un état 
        try:
            maximum = max(self.Q[state], key=self.Q[state].get)
            return (self.Q[state][maximum])
        except:
            return 0

    
    def update_q_table(self, reward, action, state, new_state, Q=None): # Mise à jour de la Q-Table en suivant l'equation décrit dans le rapport
        if self.type=="expert": return
        state = str(state)
        new_state = str(new_state)
        if Q!=None:
            self.Q = Q
        if str(state) in self.Q:
            self.Q[str(state)][action] = self.Q[state][action] + self.beta * (reward + self.gamma * self.optimal_value(new_state) - self.Q[str(state)][action])
        else:
            self.Q[str(state)] = {}
            self.Q[str(state)]['up'] = 0
            self.Q[str(state)]['down'] = 0
            self.Q[str(state)]['left'] = 0
            self.Q[str(state)]['right'] = 0
            self.Q[str(state)]['stay'] = 0
            self.Q[str(state)][action] = self.Q[state][action] + self.beta * (reward + self.gamma * self.optimal_value(new_state) - self.Q[str(state)][action])
        
        if self.save:
            self.rewards_history.append(reward)
            self.actions_history.append(action)
            self.states_history.append(state)
            self.new_states_history.append(new_state)
            

    def replay_memory(self,  rewards, actions, states, new_states): # Apprentissage depuis la mémoire d'un agent
        if self.type=="expert": return
        if self.type=="dead": return
        for i in range(len(states)):
            self.update_q_table(rewards[i], actions[i], states[i], new_states[i])

        
    def get_memory(self):  #  Récupére la mémoire de  l'agent
        if self.type=="expert": return
        if self.type=="dead": return
        l = [self.rewards_history, self.actions_history, self.states_history, self.new_states_history]
        self.rewards_history = []
        self.actions_history = []
        self.states_history = []
        self.new_states_history = []
        return l
        
    def move(self, direction):
        if self.type=="dead": return
        if not self.world_wraps:
            if direction == "up" and self.posy<self.grid_length:
                self.posy += 1
            elif direction == "down" and self.posy>0:
                self.posy -= 1
            elif direction == "left" and self.posx>0:
                self.posx -= 1
            elif direction == "right" and self.posx<self.grid_width:
                self.posx += 1
            else:
                pass
        else:
            if direction == "up": 
                self.posy += 1
            elif direction == "down":
                self.posy -= 1
                
            elif direction == "left":
                self.posx -= 1
                
            elif direction == "right":
                self.posx += 1
                
            else:
                pass        
            if self.posy>=self.grid_length:
                self.posy = 0
            if self.posy<0:
                self.posy = self.grid_length-1
            if self.posx<0:
                self.posx = self.grid_width-1
            if self.posx>=self.grid_width:
                self.posx = 0
            
class RL:
    def __init__(self, beta, gamma, grid_width, grid_length, radius=4, radius_scout=2, world_wraps = False, sharing_q_table=False, mean_frequency=0, number_to_catch=1, epsilon=0, decay_rate=0, communicating_hunters=False, teaching=False, passive=True):
        self.world_wraps = world_wraps
        self.radius = radius
        self.radius_scout = radius_scout
        self.communicating_hunters = communicating_hunters
        self.agents = []
        self.state_size = 50
        self.action_size = 4
        self.beta = beta
        self.gamma = gamma
        self.grid_width = grid_width
        self.grid_length = grid_length
        self.episode_number = 1
        self.steps = 0
        self.scouts = 0
        self.sharing_q_table = sharing_q_table
        self.Q = {}
        self.mean_frequency = mean_frequency
        self.number_to_catch = number_to_catch
        self.epsilon = epsilon
        self.decay_rate = decay_rate
        self.grid = []
        self.mean = 0
        self.mean50 = 0
        self.end = False
        self.teaching = teaching
        self.winners = []
        self.passive = passive
        
    def get_grid(self): # Récupére une représentation sous forme de grille de l'environnement à cet instant
        grid = np.zeros((self.grid_length, self.grid_width), dtype=np.uint64)
        for i in self.agents:
            if i.type == "prey":
                if grid[i.posy, i.posx] == 1:
                    grid[i.posy, i.posx] = 3
                else:
                    grid[i.posy, i.posx] = 2
            elif i.type == "hunter":
                if grid[i.posy, i.posx]==2:
                    grid[i.posy, i.posx] = 3
                else:
                    grid[i.posy, i.posx] = 1
        self.grid = grid

    
    def get_state(self, posx, posy, hunter=False): # Récupére la perception d'un agent à une position donnée
        self.get_grid()
        state = []
        if not hunter:
            rad = self.radius_scout
        else:
            rad = self.radius
        for x in range(posx-rad, posx+rad+1):
            ranger = []
            for y in range(posy-rad, posy+rad+1):
                if not self.world_wraps:
                    if x>=0 and y>=0 and x<self.grid_width and y<self.grid_length:
                        ranger.append(int(self.grid[y, x]))
                else:
                    ranger.append(int(self.grid[y%self.grid_length, x%self.grid_width]))
            state.append(ranger)
        state = dist_from_center(np.array(state), self.radius)
        if hunter and state[0] == 0 and self.scouts>0:  # If there is a scout get best value between his perception and  the hunter perception
            for j in self.agents:
                if j.type == "scout": # IF THERE IS A SCOUT ADD HIS PERCEPTION TO THE STATE
                    scout = self.get_state(j.posx, j.posy, hunter=False)
                    ret = str([scout, absolute_distance(posx, j.posx, posy, j.posy, self.grid_length)])
                    return ret
        return state

    def iteration(self): # Function to use for each iteration
        self.winners = []
        end = False
        if not self.communicating_hunters:   # Cas normal ( pas de  communication entre agents )
            for i in self.agents:
                if i.intelligent:
                    state = self.get_state(i.posx, i.posy, hunter=True)
                    action = i.choose(state)
                    i.move(action)
                    new_state = self.get_state(i.posx, i.posy, hunter=True)
                    if self.is_end_episode():
                        reward = 1
                        end = True
                    else:
                        reward = -0.1
                    i.update_q_table(reward ,action, state, new_state)
                    if reward == 1 and self.teaching:   # Sauvegarde de l'historique pour le partage d'expériences
                        replay = i.get_memory()
                        for j in self.agents:
                            if j.intelligent and self.agents.index(i)!=self.agents.index(j):  
                                j.replay_memory(replay[0], replay[1], replay[2], replay[3])
                else:
                    i.move(i.choose())
                if end:
                    break
        else:       # Agents communiquant
            if self.passive: # S'observant  passivement
                states = {}
                actions = {}
                new_states = {}
                
                for i in self.agents:
                    if i.intelligent:
                        distances = []
                        for j in self.agents:
                            if j.intelligent and self.agents.index(j)!=self.agents.index(i):
                                distances.append([i.posx-j.posx, i.posy-j.posy])        # Récupére les distances vers chaque agent
                        state = [self.get_state(i.posx, i.posy, hunter=True), distances]
                        states[str(self.agents.index(i))] = state
                        action = i.choose(state)
                        actions[str(self.agents.index(i))] = action
                        i.move(action)
                        distances = []
                        for j in self.agents:
                            if j.intelligent and self.agents.index(j)!=self.agents.index(i):
                                    distances.append([i.posx-j.posx, i.posy-j.posy])
                        if self.is_end_episode():
                            end = True
                        new_state = [self.get_state(i.posx, i.posy, hunter=True), distances]
                        new_states[str(self.agents.index(i))] = new_state
                        
                for i in self.agents:
                    if i.intelligent:
                        if end:
                            reward = 1
                        else:
                            reward = -0.1
                        i.update_q_table(reward ,actions[str(self.agents.index(i))], states[str(self.agents.index(i))], new_states[str(self.agents.index(i))])
                    else:
                        i.move(i.choose())
            else:   # Partage actif des sensations
                states = {}
                actions = {}
                new_states = {}
                
                for i in self.agents:
                    if i.intelligent:
                        distances = []
                        stats = []
                        for j in self.agents:
                            if j.intelligent and self.agents.index(j)!=self.agents.index(i):
                                distances.append([i.posx-j.posx, i.posy-j.posy])        #  Ajout des distances vers les autres agents
                                stats.append(self.get_state(j.posx, j.posy, hunter=True))  # Ajout des états des autres chasseurs
                        state = [self.get_state(i.posx, i.posy, hunter=True), stats ,distances]
                        states[str(self.agents.index(i))] = state

                        action = i.choose(state)
                        actions[str(self.agents.index(i))] = action
                        i.move(action)
                        distances = []
                        stats = []
                        for j in self.agents:
                            if j.intelligent and self.agents.index(j)!=self.agents.index(i):
                                    distances.append([i.posx-j.posx, i.posy-j.posy])
                                    stats.append(self.get_state(j.posx, j.posy, hunter=True))
                        if self.is_end_episode():
                            end = True
                        new_state = [self.get_state(i.posx, i.posy, hunter=True), stats ,distances]
                        new_states[str(self.agents.index(i))] = new_state

                        
                for i in self.agents:
                    if i.intelligent:
                        if end:
                            reward = 1
                        else:
                            reward = -0.1
                        i.update_q_table(reward ,actions[str(self.agents.index(i))], states[str(self.agents.index(i))], new_states[str(self.agents.index(i))])
                    else:
                        i.move(i.choose())


        if end:      # Si l'episode est terminé, l'environnement est réinitalisé
            self.episode_number += 1

            self.reinit()
            r = self.steps 
            if self.mean_frequency>0: # Si il y'a une fréquence de synchronisation  on moyenne les Q-Table
                if self.episode_number%self.mean_frequency == 0:
                    qss = []
                    for  i in self.agents:
                        qss.append(i.Q)
                    result  = mean_tables(qss)
                    for i in self.agents:
                        i.Q = result
            self.mean = ((self.mean*(self.episode_number-1))+r)/self.episode_number
            if self.episode_number%50==0:
                self.mean50 = 0
            else:
                self.mean50 = ((self.mean50*(self.episode_number%50-1))+r)/(self.episode_number%50)
            self.steps = 0
            return r
        self.steps += 1
        return 0
        
    def is_end_episode(self):
        preys_coord = []
        for i in self.agents:
            if i.type == "prey":
                preys_coord.append((i.posx, i.posy))
        if self.number_to_catch<2:  #  Cas normal 
            count = 0
            for i in self.agents:
                if (i.type == "hunter" or i.type=="expert") and (i.posx, i.posy) in preys_coord:
                    count += 1
            
            if count>=self.number_to_catch:
                self.end = True
                return True
            self.end = False
            return False
        else:       # Tache jointe
            for i in preys_coord:
                count = 0
                be_in = []  # Récupére l'ensemble des coordonnées dans un rayon de 1 de la proie
                be_in.append(((i[0]-1)%self.grid_length, (i[1]-1)%self.grid_length))
                be_in.append(((i[0]-1)%self.grid_length, i[1]%self.grid_length))
                be_in.append(((i[0]-1)%self.grid_length, (i[1]+1)%self.grid_length))
                    
                be_in.append((i[0]%self.grid_length, (i[1]-1)%self.grid_length))
                be_in.append((i[0]%self.grid_length, i[1]%self.grid_length))
                be_in.append((i[0]%self.grid_length, (i[1]+1)%self.grid_length))
                    
                be_in.append(((i[0]+1)%self.grid_length, (i[1]-1)%self.grid_length))
                be_in.append(((i[0]+1)%self.grid_length, i[1]%self.grid_length))
                be_in.append(((i[0]+1)%self.grid_length, (i[1]+1)%self.grid_length))
                for j in self.agents:   # Si le nombre de chasseurs dans  cet entourage est suffisant on retourne vrai
                    if j.intelligent and (j.posx, j.posy) in be_in:
                        self.winners.append(self.agents.index(j))
                        count += 1
                if count >= 2:
                    return True
            
            self.winners = []
            return False
         
    def reward(self, agent):
        preys_coord = []
        rew = -0.1
        for i in self.agents:
            if i.type == "prey":
                preys_coord.append((i.posx, i.posy))
        if (agent.posx, agent.posy) in preys_coord:
                rew = 1
        agent.rewards.append(rew)
        agent.update_q_table()

    def reinit(self):   # On reinitialise les positions des agents
        for i in self.agents:
            i.place(np.random.randint(1, 10), np.random.randint(1, 10))

    def pprint(self):    
        ret = ""    
        ret += "Episode "+str(self.episode_number)+"\n"
        ret += "Sharing-Q-Table = "+str(self.sharing_q_table)+"\n"
        ret += "Mean-Frequency =  "+str(self.mean_frequency)+"\n"
        ret += "Number to catch = "+str(self.number_to_catch)+"\n"

        ret += "Mean overall = " +str(self.mean)+"\n"
        ret += "Mean on last 50 episodes  = "+str(self.mean50)+"\n\n"

        for i in self.agents:
            if i.type!="dead":
                ret += "Agent "+str(self.agents.index(i))+"\n"
                ret += i.pprint()
                ret += "\n"
        return ret
    
    def delete_agent(self, index):
        self.agents[index].type = "dead"
    
    def print_q(self, ida): # Print Q-Table of an  agent designed by its ID
        lis = list(self.agents[ida].Q.keys())
        print("\n\nKeys")
        for i in lis:
            print(str(i))
            
    def add_hunter(self, posx, posy):
        ag = Agent(posx, posy, self.state_size, self.action_size, self.beta, self.gamma, "hunter", self.grid_width, self.grid_length, intelligent=True, world_wraps=self.world_wraps, epsilon=self.epsilon, decay_rate=self.decay_rate, save=self.teaching)
        self.agents.append(ag)

    def add_scout(self, posx, posy):
        ag = Agent(posx, posy, self.state_size, self.action_size, self.beta, self.gamma, "scout", self.grid_width, self.grid_length, intelligent=False, world_wraps=self.world_wraps)
        self.agents.append(ag)
        self.scouts += 1
        
    def add_expert(self, posx, posy):
        ag = Agent(posx, posy, self.state_size, self.action_size, self.beta, self.gamma, "expert", self.grid_width, self.grid_length, intelligent=True, world_wraps=self.world_wraps, epsilon=self.epsilon, decay_rate=self.decay_rate)
        self.agents.append(ag)
    
    def add_prey(self, posx, posy):
        ag = Agent(posx, posy, self.state_size, self.action_size, self.beta, self.gamma, "prey", self.grid_width, self.grid_length, world_wraps=self.world_wraps)
        self.agents.append(ag)
        