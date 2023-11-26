# Modèle AMPL pour l'optimisation du transport de bois

# Ensembles
set FORETS; # Ensemble des secteurs forestiers
set SCIERIES; # Ensemble des scieries
set RABOTAGES; # Ensemble des raboteries
set CLIENTS; # Ensemble des clients
set ESSENCES; # Ensemble des espèces de bois (SPF, Sapin)
set JOURS; # Ensemble des jours
set MODES_TRANSPORT; # Ensemble général des modes de transport

# Ensemble et paramètre pour le client urgent
# set URGENT_CLIENTS within CLIENTS; # Définir un sous-ensemble pour les clients urgents 
# param Demande_basse_urgente {URGENT_CLIENTS, ESSENCES} >= 0; # Demande minimale pour les clients urgents

# Paramètres pour les distances
param Distance_foret_scie {FORETS, SCIERIES} >= 0; # Distance entre les secteurs forestiers et les scieries
param Distance_scie_rabotage {SCIERIES, RABOTAGES} >= 0; # Distance entre les scieries et les raboteries
param Distance_rabotage_client {RABOTAGES, CLIENTS} >= 0; # Distance entre les raboteries et les clients pour chaque mode de transport

# Paramètres pour les ratios d'efficacité
param EFF_SCIE {SCIERIES} >= 0, <= 1; # Ratio d'efficacité pour les scieries
param EFF_RABOT {RABOTAGES} >= 0, <= 1; # Ratio d'efficacité pour les raboteries

# Paramètres pour les volumes et les demandes
param Demande_basse {CLIENTS, ESSENCES} >= 0; # Volume de bois minimal requis par les clients
param Demande_haute {CLIENTS, ESSENCES} >= 0; # Volume de bois maximal requis par les clients
param Droit_de_coupe {FORETS, JOURS} >= 0 ; # Paramètre binaire pour les droits de coupe par jour pour chaque secteur forestier

# Paramètres pour les coûts et les capacités
param Cout_recolte {FORETS} >= 0; # Coût de la récolte dans les secteurs forestiers
param Cout_transport_pre_rabotage >= 0; # Coût du transport du bois des forêts aux scieries
param Cout_transport_rabotage_client {MODES_TRANSPORT} >= 0; # Coût du transport du bois des raboteries aux clients pour chaque mode de transport
param Cout_scie {SCIERIES} >= 0; # Coût du traitement du bois dans les scieries
param Cout_rabotage {RABOTAGES} >= 0; # Coût du traitement du bois dans les raboteries
param Cap_foret {FORETS, ESSENCES} >= 0; # Capacité des forêts
param Cap_scie {SCIERIES, ESSENCES} >= 0; # Capacité des scieries
param Cap_rabotage {RABOTAGES, ESSENCES} >= 0; # Capacité des raboteries

# Variables de décision
var A {FORETS, SCIERIES, ESSENCES, JOURS} >= 0; # Volume de forêts aux scieries
var B {SCIERIES, RABOTAGES, ESSENCES, JOURS} >= 0; # Volume des scieries aux raboteries
var C {RABOTAGES, CLIENTS, ESSENCES, JOURS, MODES_TRANSPORT} >= 0; # Volume des raboteries aux clients pour chaque mode de transport
var Y {FORETS} binary; # Binaire pour le choix du secteur forestier (tout ou rien)
var entrer_secteur {FORETS, JOURS} binary; # Binaire pour l'entrée dans un secteur par jour
# var UrgentSatisfait {URGENT_CLIENTS, ESSENCES} binary; # Binaire pour les clients urgents


# Fonction objectif
minimize Cout_Total:
    sum {f in FORETS} Cout_recolte[f] * Y[f] +
    sum {f in FORETS, s in SCIERIES, e in ESSENCES, j in JOURS} Cout_transport_pre_rabotage * Distance_foret_scie[f, s] * A[f, s, e, j] +
    sum {s in SCIERIES, r in RABOTAGES, e in ESSENCES, j in JOURS} (Cout_scie[s] + Cout_transport_pre_rabotage * Distance_scie_rabotage[s, r]) * B[s, r, e, j] +
    sum {r in RABOTAGES, c in CLIENTS, e in ESSENCES, j in JOURS, m in MODES_TRANSPORT} (Cout_rabotage[r] + Cout_transport_rabotage_client[m] * Distance_rabotage_client[r, c]) * C[r, c, e, j, m];

# Contraintes

# Contrainte pour prioriser le client urgent



# Contraintes de décision de récolte
subject to DecisionRecolte {f in FORETS, j in JOURS, e in ESSENCES}: 
    sum {s in SCIERIES} A[f, s, e, j] <= Cap_foret[f, e] * Y[f];

subject to PermissionRecolte {f in FORETS, j in JOURS}:
    entrer_secteur[f, j] <= Droit_de_coupe[f, j];

subject to EntreeSecteur {f in FORETS, j in JOURS, e in ESSENCES}:
    sum {s in SCIERIES} A[f, s, e, j] <= Cap_foret[f, e] * entrer_secteur[f, j];

# Contraintes de capacité et de demande
subject to ContrainteApprovisionnement {f in FORETS, e in ESSENCES, j in JOURS}:
    sum {s in SCIERIES} A[f, s, e, j] <= Cap_foret[f, e];

subject to CapaciteScierie {s in SCIERIES, e in ESSENCES, j in JOURS}:
    sum {f in FORETS} A[f, s, e, j] <= Cap_scie[s, e];

subject to CapaciteRabotage {r in RABOTAGES, e in ESSENCES, j in JOURS}:
    sum {s in SCIERIES} B[s, r, e, j] <= Cap_rabotage[r, e];

subject to ContrainteDemande {c in CLIENTS, e in ESSENCES}:
    Demande_basse[c, e] <= sum {r in RABOTAGES, m in MODES_TRANSPORT, j in JOURS} C[r, c, e, j, m] <= Demande_haute[c, e];

# Conservation du flux de la scierie à la raboterie avec le ratio d'efficacité de la scierie
subject to ConservationFlux_Scieries {s in SCIERIES, e in ESSENCES, j in JOURS}:
    sum {f in FORETS} A[f, s, e, j] * EFF_SCIE[s] = sum {r in RABOTAGES} B[s, r, e, j];

# Conservation du flux de la raboterie au client avec le ratio d'efficacité de la raboterie
subject to ConservationFlux_Rabotages {r in RABOTAGES, e in ESSENCES, j in JOURS}:
    sum {s in SCIERIES} B[s, r, e, j] * EFF_RABOT[r] = sum {c in CLIENTS, m in MODES_TRANSPORT} C[r, c, e, j, m];

