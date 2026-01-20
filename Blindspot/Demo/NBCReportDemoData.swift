import Foundation

enum NBCReportDemoData {
    // Use a raw string literal to avoid accidental escape/newline issues in JSON.
    static let json: String = #"""
{
  "date": "2026-01-18",
  "generatedAt": "2026-01-18T00:00:00Z",
  "location": "Local Demo",
  "source": {
    "name": "NBC News Top Stories (Demo)",
    "link": "https://feeds.nbcnews.com/nbcnews/public/news"
  },
  "topics": [
    {
      "sourceTitle": "News summary",
      "sourceLink": "https://feeds.nbcnews.com/nbcnews/public/news",
      "topicName": "Power and resources: why Arctic trade tensions keep escalating",
      "firstPrinciples": "Competition for power and scarce resources is a persistent driver of international politics. Strategic geography and critical minerals amplify rivalry, while tariffs serve as leverage to force concessions on larger issues. When nationalist, interest-first narratives rise, even traditional allies face friction.",
      "businessOpportunity": "Critical-mineral supply chain diversification advisory; geopolitical risk monitoring and hedging for multinationals; sustainable Arctic infrastructure and resource investment research for funds and strategic investors.",
      "futureRoadmap": "Next 30 days: map exposure to tariffs and critical inputs, publish a risk brief for key stakeholders, monitor multilateral forums and policy signals. Next 2 years: expect elevated competition for strategic regions and inputs; invest in traceability, alternative sourcing, and resilient logistics."
    },
    {
      "sourceTitle": "News summary",
      "sourceLink": "https://feeds.nbcnews.com/nbcnews/public/news",
      "topicName": "Loneliness goes viral: the rise of low-friction wellbeing check-ins",
      "firstPrinciples": "Loneliness is a universal human emotion, but modern living patterns and digital-first social norms can intensify isolation. Viral content spreads collective anxiety quickly. Many \"dark\" memes are really a demand for connection, meaning, and lightweight support systems.",
      "businessOpportunity": "Privacy-first check-in and safety workflows for friends/families; community-based mental health support tooling; content and habit products that turn reactive doom-scrolling into proactive connection.",
      "futureRoadmap": "Next 30 days: test a simple check-in flow and retention loop; partner with communities; build guardrails for safety escalation. Next 2 years: expect more demand for companionship and community products; AI-assisted support will expand but must be trustable."
    },
    {
      "sourceTitle": "NBC RSS",
      "sourceLink": "https://feeds.nbcnews.com/nbcnews/public/news",
      "topicName": "Extreme weather alerts: resilience becomes a product feature, not a slogan",
      "firstPrinciples": "Climate volatility exposes infrastructure and household preparedness gaps. Safety is a foundational need; prevention and response require coordination across public systems, private services, and individual behaviors.",
      "businessOpportunity": "Municipal emergency operations dashboards; household preparedness kits and subscriptions; climate-adaptive infrastructure planning and analytics for cities and developers.",
      "futureRoadmap": "Next 30 days: map regional risk, create incident playbooks, and run tabletop drills. Next 2 years: increased spend on adaptation, better forecasting, and growth in response tooling and insurance-aligned products."
    }
  ]
}
"""#

    static let emailHTML: String = #"""
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Blindspot Demo Report</title>
  </head>
  <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial; background: #ffffff; margin: 0; padding: 24px;">
    <div style="max-width: 640px; margin: 0 auto;">
      <h2 style="margin: 0 0 8px;">Blindspot Demo Report</h2>
      <p style="margin: 0 0 18px; color: #555;">This is local demo content (English). Use it to validate UI layout and copy/share flows.</p>

      <div style="background: #E7E5FF; border-radius: 18px; padding: 16px; margin: 0 0 14px;">
        <h3 style="margin: 0 0 8px;">Power and resources</h3>
        <p style="margin: 0; font-size: 14px;"><strong>🧬 First principles:</strong> Competition for power and scarce resources drives recurring geopolitical cycles.</p>
        <p style="margin: 8px 0 0; font-size: 14px;"><strong>💰 Opportunity:</strong> Supply-chain risk tooling and critical mineral diversification advisory.</p>
        <p style="margin: 8px 0 0; font-size: 14px;"><strong>🗺️ Roadmap:</strong> Map exposure, monitor policy signals, invest in resilience.</p>
      </div>
    </div>
  </body>
</html>
"""#
}

