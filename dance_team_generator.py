"""
DANCE TEAM GENERATOR - Python Implementation
============================================

Enhanced pyramid matchmaking for dance teams with:
- Auto-generated team names
- Photo URL support (Abby Lee placeholder)
- Genre mixing for diversity
- Batch processing capability

Usage:
    python dance_team_generator.py

"""

import pandas as pd
import numpy as np
import json
from typing import List, Dict, Tuple, Optional
import random


class DanceTeamGenerator:
    """Generate dance teams using pyramid structure with auto-naming"""
    
    def __init__(self, form_responses_path: str):
        """
        Initialize with Form Responses data
        
        Args:
            form_responses_path: Path to Form_Responses_Raw.xlsx
        """
        self.df = pd.read_excel(form_responses_path)
        
        # Abby Lee Miller placeholder
        self.abby_placeholder = "https://media.giphy.com/media/l0HlUJZE8Uo1cSlUI/giphy.gif"
        
        # Column mappings (0-indexed)
        self.cols = {
            'screen_name': 'Screen Name',
            'uid': 'UID',
            'checked_in': 'Checked-In',
            'photo_url': 'PHOTO_URL_COL',
            'age': 'Age Range',
            'interest_1': 'Your General Interests (Choose 3)',
            'music': 'Music Preference',
            'industry': 'Employment Information (Industry)',
            'zodiac': 'Zodiac Sign'
        }
        
        # Get checked-in guests (or all if no check-in column)
        if 'Checked-In' in self.df.columns:
            self.guests = self.df[self.df['Checked-In'] == 'Y'].copy()
        else:
            # If no check-in data, use all guests
            self.guests = self.df.copy()
        
        print(f"Loaded {len(self.guests)} guests")
        
    def calculate_similarity(self, guest_a: pd.Series, guest_b: pd.Series, 
                           mix_genres: bool = True) -> float:
        """
        Calculate similarity between two guests
        
        Args:
            guest_a: First guest data
            guest_b: Second guest data
            mix_genres: If True, reduce weight for same music genre
            
        Returns:
            Similarity score (0-1)
        """
        matches = 0
        comparisons = 0
        
        # Parse interests (comma-separated string)
        interests_a = str(guest_a.get(self.cols['interest_1'], '')).split(',')
        interests_a = [i.strip() for i in interests_a if i.strip()]
        
        interests_b = str(guest_b.get(self.cols['interest_1'], '')).split(',')
        interests_b = [i.strip() for i in interests_b if i.strip()]
        
        # Interest overlap (high weight)
        for int_a in interests_a:
            if int_a in interests_b:
                matches += 2
        comparisons += 6  # Max possible
        
        # Age range
        age_a = guest_a.get(self.cols['age'])
        age_b = guest_b.get(self.cols['age'])
        if pd.notna(age_a) and pd.notna(age_b):
            comparisons += 1
            if age_a == age_b:
                matches += 1
        
        # Music preference
        music_a = guest_a.get(self.cols['music'])
        music_b = guest_b.get(self.cols['music'])
        if pd.notna(music_a) and pd.notna(music_b):
            comparisons += 1
            if music_a == music_b:
                matches += 0.5 if mix_genres else 1
            elif mix_genres:
                matches += 0.3  # Bonus for different genres
        
        return matches / comparisons if comparisons > 0 else 0
    
    def select_diverse_genres(self, candidates: List[Dict], count: int, 
                             focal_genre: str) -> List[Dict]:
        """
        Select guests with diverse music genres
        
        Args:
            candidates: List of candidate guests with similarity scores
            count: Number to select
            focal_genre: Focal guest's music genre
            
        Returns:
            List of selected guests
        """
        selected = []
        used_genres = {focal_genre}
        
        # First pass: pick different genres
        for candidate in candidates:
            if len(selected) >= count:
                break
            genre = candidate.get('music')
            if genre and genre not in used_genres:
                selected.append(candidate)
                used_genres.add(genre)
        
        # Second pass: fill remaining with best matches
        for candidate in candidates:
            if len(selected) >= count:
                break
            if not any(s['uid'] == candidate['uid'] for s in selected):
                selected.append(candidate)
        
        return selected[:count]
    
    def build_pyramid(self, focal_uid: str, mix_genres: bool = True) -> Dict:
        """
        Build a dance team pyramid for a focal guest
        
        Args:
            focal_uid: UID of focal guest
            mix_genres: Mix genres for diversity
            
        Returns:
            Pyramid structure with team data
        """
        # Find focal guest
        focal = self.guests[self.guests[self.cols['uid']] == focal_uid]
        if focal.empty:
            return {'ok': False, 'message': 'Guest not found'}
        
        focal = focal.iloc[0]
        
        # Calculate similarities to all other guests
        similarities = []
        for idx, guest in self.guests.iterrows():
            if guest[self.cols['uid']] == focal_uid:
                continue
            
            sim = self.calculate_similarity(focal, guest, mix_genres)
            
            # Parse interests for this guest
            interests = str(guest.get(self.cols['interest_1'], '')).split(',')
            interests = [i.strip() for i in interests if i.strip()]
            
            similarities.append({
                'uid': guest[self.cols['uid']],
                'screenName': guest[self.cols['screen_name']],
                'similarity': sim,
                'music': guest.get(self.cols['music'], 'Various'),
                'age': guest.get(self.cols['age']),
                'interests': interests[:3],
                'photoUrl': guest.get(self.cols['photo_url']) if pd.notna(guest.get(self.cols['photo_url'])) else self.abby_placeholder
            })
        
        if len(similarities) < 5:
            return {'ok': False, 'message': 'Not enough guests for pyramid'}
        
        # Sort by similarity
        similarities.sort(key=lambda x: x['similarity'], reverse=True)
        
        # Row 2: Select with genre diversity
        focal_genre = focal.get(self.cols['music'], 'Various')
        row2 = self.select_diverse_genres(similarities[:10], 2, focal_genre)
        
        # Row 3: Select from remaining
        remaining = [s for s in similarities if s['uid'] not in [r['uid'] for r in row2]]
        row3 = self.select_diverse_genres(remaining, 3, focal_genre)
        
        # Parse focal interests
        focal_interests = str(focal.get(self.cols['interest_1'], '')).split(',')
        focal_interests = [i.strip() for i in focal_interests if i.strip()][:3]
        
        # Build pyramid
        pyramid = {
            'ok': True,
            'focal': {
                'uid': focal[self.cols['uid']],
                'screenName': focal[self.cols['screen_name']],
                'interests': focal_interests,
                'music': focal_genre,
                'age': focal.get(self.cols['age']),
                'photoUrl': focal.get(self.cols['photo_url']) if pd.notna(focal.get(self.cols['photo_url'])) else self.abby_placeholder
            },
            'row2': [{
                'uid': g['uid'],
                'screenName': g['screenName'],
                'similarity': round(g['similarity'], 4),
                'music': g['music'],
                'photoUrl': g['photoUrl']
            } for g in row2],
            'row3': [{
                'uid': g['uid'],
                'screenName': g['screenName'],
                'similarity': round(g['similarity'], 4),
                'music': g['music'],
                'photoUrl': g['photoUrl']
            } for g in row3],
            'stats': {
                'avgSimilarity': round(sum(g['similarity'] for g in row2 + row3) / 5, 4),
                'topMatch': round(max(g['similarity'] for g in row2), 4),
                'genreMix': len(set([focal_genre] + [g['music'] for g in row2 + row3]))
            }
        }
        
        # Generate team name
        pyramid['teamName'] = self.generate_team_name(pyramid)
        pyramid['abbyPhoto'] = self.abby_placeholder
        
        return pyramid
    
    def generate_team_name(self, pyramid: Dict) -> str:
        """
        Generate creative team name based on collective traits
        
        Args:
            pyramid: Pyramid structure
            
        Returns:
            Team name string
        """
        # Collect all members
        all_members = [pyramid['focal']] + pyramid['row2'] + pyramid['row3']
        
        # Analyze traits
        music_genres = set(m.get('music', 'Various') for m in all_members if m.get('music'))
        age_ranges = set(m.get('age') for m in all_members if m.get('age'))
        
        # Count interests
        interests = {}
        for m in all_members:
            for interest in m.get('interests', []):
                if interest:
                    interests[interest] = interests.get(interest, 0) + 1
        
        dominant_interest = max(interests.keys(), key=lambda k: interests[k]) if interests else None
        
        # Genre-based names
        genre_names = {
            'Pop': ['Pop Perfection', 'Pop Dynasty', 'Pop Royalty', 'Chart Toppers'],
            'Hip-hop': ['Hip-Hop Heat', 'Rap Rebellion', 'Beat Brigade', 'Flow Masters'],
            'R&B': ['R&B Royalty', 'Smooth Operators', 'Soul Squad', 'Velvet Voices'],
            'Rock': ['Rock Legends', 'Rebel Rockers', 'Stone Cold Crew', 'Rock Revolution'],
            'Indie/Alt': ['Indie Icons', 'Alt Elite', 'Underground Kings', 'Indie Vanguard'],
            'Country': ['Country Crew', 'Nashville Ninjas', 'Honky Tonk Heroes', 'Country Classics'],
            'Electronic': ['Electric Energy', 'Bass Battalion', 'Synth Squad', 'EDM Empire']
        }
        
        # Interest-based names
        interest_names = {
            'Music': ['Harmony Squad', 'Rhythm Rebels', 'Note Worthy'],
            'Fitness': ['Flex Force', 'Gym Legends', 'Fit Fam'],
            'Gaming': ['Level Up Crew', 'Controller Kings', 'Game Changers'],
            'Fashion': ['Style Squad', 'Fashion Forward', 'Runway Rebels'],
            'Art/Design': ['Creative Collective', 'Art Attack', 'Design Dynasty'],
            'Cooking': ['Kitchen Commanders', 'Flavor Force', 'Chef Squad'],
            'Travel': ['Jet Setters', 'Globe Trotters', 'Adventure Squad']
        }
        
        # Name selection
        genres_list = list(music_genres)
        
        # Strong genre unity
        if len(genres_list) == 1 and genres_list[0] in genre_names:
            return random.choice(genre_names[genres_list[0]])
        
        # Dominant interest
        if dominant_interest:
            for key in interest_names:
                if key in dominant_interest:
                    return random.choice(interest_names[key])
        
        # Multi-genre mix
        if len(genres_list) >= 3:
            mix_names = [
                'Genre Fusion', 'Mixed Vibes', 'Eclectic Energy',
                'Diverse Dynasty', 'Spectrum Squad', 'All-Star Mix'
            ]
            return random.choice(mix_names)
        
        # Default
        default_names = [
            'Dance Dynasty', 'Rhythm Royalty', 'Move Makers', 'Beat Squad',
            'Flow Force', 'Vibe Tribe', 'Energy Elite', 'Motion Crew',
            'Groove Gang', 'Step Squad', 'Dance Rebels', 'Stage Stars'
        ]
        return random.choice(default_names)
    
    def generate_teams(self, count: int = 15, allow_repeat: bool = True) -> List[Dict]:
        """
        Generate multiple dance teams
        
        Args:
            count: Number of teams to generate
            allow_repeat: Allow guests in multiple teams (not as focal twice)
            
        Returns:
            List of pyramid structures
        """
        if len(self.guests) < 6:
            return [{'ok': False, 'message': 'Need at least 6 guests for teams'}]
        
        teams = []
        used_focals = set()
        
        # Shuffle guests
        guest_uids = self.guests[self.cols['uid']].tolist()
        random.shuffle(guest_uids)
        
        for i in range(min(count, len(guest_uids))):
            # Pick focal (not used before)
            focal_uid = None
            for uid in guest_uids:
                if uid not in used_focals:
                    focal_uid = uid
                    used_focals.add(uid)
                    break
            
            if not focal_uid:
                break
            
            # Build pyramid
            pyramid = self.build_pyramid(focal_uid)
            
            if pyramid['ok']:
                pyramid['teamNumber'] = i + 1
                teams.append(pyramid)
        
        return teams
    
    def generate_abby_quote(self, team: Dict) -> str:
        """
        Generate Abby Lee-style commentary
        
        Args:
            team: Dance team structure
            
        Returns:
            Abby-style quote
        """
        focal = team['focal']['screenName']
        team_name = team['teamName']
        top_match = team['stats']['topMatch']
        genre_mix = team['stats']['genreMix']
        
        high_quotes = [
            f"{focal}, you're leading {team_name} and that top {int(top_match * 100)}% match? *Chef's kiss*",
            f"This is what I'm TALKING about! {team_name} has the chemistry to WIN.",
            f"{focal}, you better bring it because {team_name} is competition-ready!",
            f"NOT {team_name} being the team to beat! {focal}, lead them to glory!"
        ]
        
        med_quotes = [
            f"{team_name}... interesting. {focal}, you've got work to do but I see potential.",
            f"{focal}, {team_name} needs discipline. Can you give it to them?",
            f"This is... fine. {team_name} can be great if they FOCUS.",
            f"{focal}, {team_name} has the raw talent. Now make it polished."
        ]
        
        low_quotes = [
            f"{focal}, I'm not sure what {team_name} is giving, but we're gonna make it work.",
            f"This is a CHALLENGE, {focal}. {team_name} needs your leadership NOW.",
            f"{team_name}? Chaos. But chaos can become art. {focal}, make me believe.",
            f"I've seen worse. {team_name}, prove me wrong about this lineup."
        ]
        
        quotes = high_quotes if top_match >= 0.6 else med_quotes if top_match >= 0.4 else low_quotes
        base = random.choice(quotes)
        
        if genre_mix >= 4:
            diversity = [
                f"And {genre_mix} different genres? This is FUSION, people!",
                f"{genre_mix} genres on one team! I love the diversity energy.",
                f"Genre mixing like this? {team_name} is here to shake things up."
            ]
            return base + ' ' + random.choice(diversity)
        
        return base
    
    def generate_visual_pyramid(self, team: Dict) -> str:
        """
        Generate ASCII art pyramid
        
        Args:
            team: Dance team structure
            
        Returns:
            ASCII pyramid string
        """
        focal = team['focal']['screenName']
        row2_names = ', '.join(m['screenName'] for m in team['row2'])
        row3_names = ', '.join(m['screenName'] for m in team['row3'])
        
        visual = f"""
╔══════════════════════════════════════════════════════════════╗
║  TEAM {team.get('teamNumber', '?')}: {team['teamName'].upper()}
╚══════════════════════════════════════════════════════════════╝

                    [{focal}]
                {team['focal'].get('music', 'Various')} | {team['focal'].get('age', 'N/A')}
                        ↓
        [{team['row2'][0]['screenName']}]              [{team['row2'][1]['screenName']}]
        {team['row2'][0]['similarity']:.1%}                    {team['row2'][1]['similarity']:.1%}
                        ↓
    [{team['row3'][0]['screenName']}]  [{team['row3'][1]['screenName']}]  [{team['row3'][2]['screenName']}]
    {team['row3'][0]['similarity']:.1%}       {team['row3'][1]['similarity']:.1%}       {team['row3'][2]['similarity']:.1%}

📊 TEAM STATS:
   Avg Compatibility: {team['stats']['avgSimilarity']:.1%}
   Top Match: {team['stats']['topMatch']:.1%}
   Genre Mix: {team['stats']['genreMix']} genres

💬 ABBY SAYS: {self.generate_abby_quote(team)}
"""
        return visual


def main():
    """Main execution"""
    import sys
    
    # Load data
    form_path = '/mnt/user-data/uploads/Form_Responses_Raw.xlsx'
    
    try:
        generator = DanceTeamGenerator(form_path)
    except Exception as e:
        print(f"Error loading data: {e}")
        print("\nNote: If you don't have checked-in guests yet, the system will use all guests.")
        print("Update the 'Checked-In' column with 'Y' for guests who are present.")
        sys.exit(1)
    
    # Generate teams
    print("\n" + "="*60)
    print("GENERATING DANCE TEAMS")
    print("="*60)
    
    teams = generator.generate_teams(count=5, allow_repeat=True)
    
    if not teams or not teams[0].get('ok', False):
        print("❌ Could not generate teams. Check data.")
        sys.exit(1)
    
    # Display results
    for team in teams:
        print(generator.generate_visual_pyramid(team))
        print("\n" + "-"*60 + "\n")
    
    # Export to JSON
    output_path = '/home/claude/dance_teams/dance_teams_output.json'
    with open(output_path, 'w') as f:
        json.dump(teams, f, indent=2)
    
    print(f"\n✅ Exported {len(teams)} teams to: {output_path}")
    print("\nReady for production! 🎉")


if __name__ == '__main__':
    main()
