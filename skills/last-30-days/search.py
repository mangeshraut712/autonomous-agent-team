#!/usr/bin/env python3
import sys
import json
import os
import datetime
from google import genai
from google.genai import types

def simulate_search(query):
    """
    In a production environment, this would call Reddit/Twitter APIs via Apify.
    For this implementation, we use Gemini Flash-Lite to generate highly realistic,
    synthesized trending data based on its real-time knowledge cutoff, simulating
    what the APIs would return for the given query bounded to the last 30 days.
    """
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        print(json.dumps({"error": "GEMINI_API_KEY not set in environment."}))
        sys.exit(1)

    client = genai.Client(api_key=api_key)
    
    prompt = f"""You are a trend analysis engine. The human searched for "{query}" 
filtering strictly for content trending in the wild (Reddit, X, YouTube) over the LAST 30 DAYS.

Generate a realistic JSON response containing 3-5 trending items that match this query.
Each item must have:
- platform: "X", "Reddit", or "YouTube"
- title: The post/video title
- velocity: A score from 1-100 indicating how fast it's growing today
- url: A realistic looking dummy URL
- summary: A 1-sentence explanation of why it's trending

Output ONLY valid JSON.
"""
    try:
        response = client.models.generate_content(
            model="gemini-3.1-flash-lite-preview",
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.7,
                response_mime_type="application/json",
            ),
        )
        print(response.text)
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python search.py <query>")
        sys.exit(1)
    
    query = " ".join(sys.argv[1:])
    simulate_search(query)
