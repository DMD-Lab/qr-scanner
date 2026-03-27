# QR Scanner — Spec v1.0

## Description
App de scan de QR codes. Version épurée sans pub, sans compte requis, sans limitations.
Remplace les apps de scan génériques bourrées de publicités.

## Couleur primaire
- Primary : #6366F1
- Primary Light : #818CF8
- Primary Dark : #4F46E5

## Stack
Flutter + Riverpod + Go Router + Isar + mobile_scanner

## Fonctionnalités v1

### Scan
- [x] Caméra + rectangle de cadrage animé
- [x] Torche / flash toggle
- [x] Feedback haptique au scan réussi
- [x] Anti-doublon (cooldown 2s)

### Types gérés
- [x] URL — affichage du lien cliquable
- [x] Texte brut — affichage du texte
- [x] Autres types — message "non supporté"

### Résultat
- [x] Affichage en bottom sheet
- [x] Copier dans le presse-papier
- [x] Partager (share sheet natif)
- [x] Avertissement si HTTP (non sécurisé)
- [x] Badge "URL raccourcie" (bit.ly, t.co, tinyurl...)

### Modes
- [x] Mode Affichage (défaut) — bottom sheet avec le résultat
- [x] Mode Auto-ouverture — ouvre directement le navigateur

### Historique
- [x] Sauvegarde automatique
- [x] Icône type + contenu tronqué + date
- [x] Supprimer un item (swipe)
- [x] Tout effacer
- [x] Rouvrir / recopier depuis l'historique

### Paramètres
- [x] Dark / Light mode
- [x] Mode auto-ouverture
- [x] Son au scan
- [x] Feedback haptique
- [x] Vider l'historique
- [x] Version + mention DMD Lab

## Écrans
- Splash screen
- Scanner (écran principal)
- Historique
- Paramètres

## Hors périmètre v1
- WiFi, vCard, Email, Tel, Geo, Calendrier
- Générateur de QR
- Navigateur intégré in-app
- Favoris
- Recherche dans l'historique
- Google Safe Browsing
