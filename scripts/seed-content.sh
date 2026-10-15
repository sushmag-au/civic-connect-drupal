#!/usr/bin/env bash
# ==============================================================================
# CivicConnect - Content Seeding Script
# Populates realistic civic services, news, and events for City of Harborview
# ==============================================================================

set -euo pipefail

# ANSI Color Codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}================================================================${NC}"
echo -e "${CYAN}   CivicConnect - Seeding Sample Content (Harborview)     ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Detect execution context
if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
  DRUSH="./vendor/bin/drush"
  [ -f "$DRUSH" ] || DRUSH="drush"
else
  # Host execution: if docker container is active, forward command
  if command -v docker >/dev/null 2>&1 && docker compose ps civicconnect_php 2>/dev/null | grep -q "Up"; then
    echo -e "${CYAN}Executing seed script inside civicconnect_php container...${NC}"
    docker compose exec -T php /var/www/html/scripts/seed-content.sh
    exit $?
  fi
  DRUSH="./vendor/bin/drush"
  [ -f "$DRUSH" ] || DRUSH="drush"
fi

echo -e "\n${YELLOW}[1/4] Ensuring Content Types (Service, News Article, Event) exist...${NC}"

$DRUSH php-eval '
use Drupal\node\Entity\NodeType;

$content_types = [
  "service" => [
    "name" => "Service",
    "description" => "Civic and municipal services offered by the City of Harborview.",
  ],
  "news_article" => [
    "name" => "News Article",
    "description" => "Official council announcements, press releases, and community news.",
  ],
  "event" => [
    "name" => "Event",
    "description" => "Community events, festivals, council meetings, and workshops.",
  ],
];

foreach ($content_types as $id => $info) {
  $type = NodeType::load($id);
  if (!$type) {
    $type = NodeType::create([
      "type" => $id,
      "name" => $info["name"],
      "description" => $info["description"],
      "display_submitted" => FALSE,
    ]);
    $type->save();
    node_add_body_field($type);
    echo "Created content type: {$info["name"]} ({$id})\n";
  } else {
    echo "Content type already exists: {$info["name"]} ({$id})\n";
  }
}
'

echo -e "\n${YELLOW}[2/4] Seeding 5 Municipal Services...${NC}"

$DRUSH php-eval '
use Drupal\node\Entity\Node;

$services = [
  [
    "title" => "Waste Collection & Resource Recovery",
    "summary" => "Residential kerbside waste, yellow recycling, and FOGO organics bin collection schedules and drop-off centres across Harborview.",
    "body" => "<p>The City of Harborview provides comprehensive waste management and circular economy resource recovery for over 110,000 households. Our weekly and fortnightly kerbside collection services include red-lid general waste, yellow-lid recycling, and lime-green lid Food Organics and Garden Organics (FOGO).</p><h3>Key Information:</h3><ul><li><strong>Collection Day Checker:</strong> Enter your address to download your 2026 waste calendar.</li><li><strong>Drop-off Centres:</strong> Harborview Resource Recovery Centre (Douro St, North Harborview) and Drysdale Resource Recovery Centre (Becks Rd).</li><li><strong>Hard Waste:</strong> Book up to two free annual hard waste collections per rateable property.</li></ul><p>For hazardous materials, paint, and electronic waste, please visit our free Detox Your Home drop-off events held biannually.</p>",
  ],
  [
    "title" => "Residential & Commercial Parking Permits",
    "summary" => "Apply for, renew, and manage residential parking permits, disability permits, and central Harborview business parking permits online.",
    "body" => "<p>Council administers designated parking permit zones across Central Harborview, Newtown, Belmont, and East Harborview to ensure fair street access for local residents and registered businesses.</p><h3>Permit Options:</h3><ul><li><strong>Resident Annual Permit:</strong> Up to two vehicles per residential household within designated permit zones.</li><li><strong>Visitor Scratch/Digital Vouchers:</strong> Short-term permits valid for guests and trade contractors.</li><li><strong>Accessible Disability Parking Scheme (ADPS):</strong> Victorian statewide accessible permits for drivers and passengers with mobility requirements.</li></ul><p>Applications require proof of residency (rates notice or lease agreement) and vehicle registration documentation.</p>",
  ],
  [
    "title" => "Council Rates & Property Valuations",
    "summary" => "Pay council rates, view Capital Improved Value (CIV) property valuations, establish direct debits, or submit financial hardship assistance.",
    "body" => "<p>Council rates fund vital community infrastructure, parks, sporting pavilions, libraries, roads, and municipal services across Harborview, the coastal peninsula, and the northern growth corridor.</p><h3>Payment Deadlines & Methods:</h3><ul><li><strong>Annual Payment:</strong> Full payment due by 15 February annually.</li><li><strong>Four Quarterly Installments:</strong> 30 September, 30 November, 28 February, and 31 May.</li><li><strong>Payment Methods:</strong> BPAY, online credit card portal, Post Billpay, or direct debit payment plans.</li><li><strong>Pensioner Concession:</strong> Eligible concession card holders receive an annual municipal rate rebate.</li></ul><p>If you are experiencing financial difficulties, please explore our confidential Financial Hardship Policy.</p>",
  ],
  [
    "title" => "Planning & Building Permits",
    "summary" => "Submit planning applications, heritage overlay reviews, tree removal permits, and building compliance approvals via our digital portal.",
    "body" => "<p>Before commencing any residential development, commercial construction, or property alteration in Harborview, check whether a planning or building permit is required under the Harborview Planning Scheme.</p><h3>Application Streams:</h3><ul><li><strong>VicSmart Fast-Track:</strong> Streamlined 10-business-day assessment for minor buildings, extensions, fences, and simple signage.</li><li><strong>Standard Planning Permit:</strong> Multi-dwelling developments, heritage overlays, subdivision, and commercial rezoning.</li><li><strong>Heritage Advice:</strong> Book a free 30-minute consultation with our heritage advisory team before lodging plans for heritage-listed properties.</li></ul><p>Track your submitted applications real-time through the online CivicConnect Planning Register.</p>",
  ],
  [
    "title" => "Community Grants & Creative Harborview Funding",
    "summary" => "Annual funding programs supporting non-profit community groups, sporting clubs, arts cultural initiatives, and climate resilience projects.",
    "body" => "<p>The City of Harborview invests over $4.5 million annually into grassroots community organisations, sporting infrastructure, arts collectives, and sustainability projects through competitive grant rounds.</p><h3>Available Categories:</h3><ul><li><strong>Community Building Grants:</strong> Grants up to $50,000 for infrastructure upgrades, disability access ramps, and community facilities.</li><li><strong>Arts & Culture Projects:</strong> Funding up to $10,000 for local exhibitions, public murals, live performances, and festival activations.</li><li><strong>Climate Action & Sustainability:</strong> Grants up to $15,000 for community solar installations, native revegetation, and urban farming.</li><li><strong>Quick Response Grants:</strong> Micro-grants up to $2,000 available year-round for urgent equipment or safety needs.</li></ul><p>Applications are reviewed by an independent council panel against published merit criteria.</p>",
  ],
];

foreach ($services as $data) {
  $query = \Drupal::entityQuery("node")
    ->condition("type", "service")
    ->condition("title", $data["title"])
    ->accessCheck(FALSE);
  $nids = $query->execute();

  if (empty($nids)) {
    $node = Node::create([
      "type" => "service",
      "title" => $data["title"],
      "status" => 1,
      "uid" => 1,
      "body" => [
        "value" => $data["body"],
        "summary" => $data["summary"],
        "format" => "basic_html",
      ],
    ]);
    $node->save();
    echo "Created Service: " . $data["title"] . " (NID: " . $node->id() . ")\n";
  } else {
    echo "Service already exists: " . $data["title"] . "\n";
  }
}
'

echo -e "\n${YELLOW}[3/4] Seeding 4 Council News Articles...${NC}"

$DRUSH php-eval '
use Drupal\node\Entity\Node;

$articles = [
  [
    "title" => "Harborview Waterfront Revitalisation Project Phase 2 Commences",
    "summary" => "A $12.5M joint investment from Council and the Victorian Government will modernise the Eastern Beach promenade and improve accessible foreshore pathways.",
    "body" => "<p>Construction has officially commenced on Phase 2 of the landmark Harborview Waterfront Revitalisation project. Spanning from Western Beach through to Eastern Beach Reserve, the project aims to future-proof one of Victoria’s most iconic regional coastlines against coastal erosion while improving accessibility for all residents.</p><p>Key milestones for the precinct include:</p><ul><li>All-abilities ramp connecting the upper promenade to the historic Art Deco Eastern Beach sea baths.</li><li>Smart energy-efficient LED lighting integrated with public Wi-Fi hotspots and environmental sensors.</li><li>Native indigenous coastal flora landscaping designed in partnership with Wadawurrung Traditional Owners.</li><li>Dedicated separated cycling and pedestrian lanes to enhance safety along the foreshore.</li></ul><p>Works are scheduled for completion ahead of the summer 2026/27 holiday peak season.</p>",
  ],
  [
    "title" => "New Community Solar & Energy Efficiency Rebate Launched",
    "summary" => "Eligible Harborview homeowners, small businesses, and community sporting clubs can access up to $3,500 in clean energy co-contributions.",
    "body" => "<p>In line with the City of Harborview’s commitment to achieving net-zero municipal emissions by 2035, Council has unveiled the 2026 Community Solar & Energy Efficiency Rebate Scheme.</p><p>Administered under the CivicConnect sustainability initiative, the $2.4M scheme provides direct financial support to households and community organisations investing in rooftop solar photovoltaics, heat-pump hot water systems, and commercial battery storage.</p><p>Eligible applicants can apply directly through the CivicConnect online portal with verified Clean Energy Council (CEC) accredited installers.</p>",
  ],
  [
    "title" => "Annual Green Waste & Mulch Collection Weekend Announced",
    "summary" => "Free residential drop-off of garden clippings, tree prunings, and organic waste will take place across North Harborview and Drysdale recovery centres.",
    "body" => "<p>To assist residents with bushfire preparedness and autumn garden maintenance, City of Harborview is offering two dedicated Free Green Waste Drop-Off Weekends this month.</p><p>Residents can dispose of residential garden clippings, tree branches (up to 200mm diameter), grass trimmings, and raw timber free of charge at:</p><ul><li><strong>North Harborview Resource Recovery Centre:</strong> Saturday & Sunday, 8:00 AM – 4:00 PM.</li><li><strong>Drysdale Resource Recovery Centre:</strong> Saturday & Sunday, 8:30 AM – 4:00 PM.</li></ul><p>Free organic compost and mulch will also be available for residents to collect on a bring-your-own-trailer basis while supplies last.</p>",
  ],
  [
    "title" => "Next-Gen Digital Planning Portal Goes Live for Harborview",
    "summary" => "The updated digital planning register provides 24/7 self-service application tracking, interactive GIS zoning maps, and automated SMS milestone updates.",
    "body" => "<p>The City of Harborview has officially retired legacy paper application workflows with the full deployment of the CivicConnect Next-Gen Planning Portal.</p><p>The decoupled portal, powered by Drupal 11 JSON:API backend services and modern cloud architecture, delivers:</p><ul><li>Real-time tracking of VicSmart and standard planning permit progress.</li><li>Interactive spatial mapping displaying nearby planning applications and public notice periods.</li><li>Secure document upload with instant validation of architectural drawings.</li><li>Public submission tools allowing neighbours to review and lodge formal responses digitally.</li></ul><p>Early trials have shown a 35% reduction in administrative processing times for standard residential permits.</p>",
  ],
];

foreach ($articles as $data) {
  $query = \Drupal::entityQuery("node")
    ->condition("type", "news_article")
    ->condition("title", $data["title"])
    ->accessCheck(FALSE);
  $nids = $query->execute();

  if (empty($nids)) {
    $node = Node::create([
      "type" => "news_article",
      "title" => $data["title"],
      "status" => 1,
      "uid" => 1,
      "body" => [
        "value" => $data["body"],
        "summary" => $data["summary"],
        "format" => "basic_html",
      ],
    ]);
    $node->save();
    echo "Created News Article: " . $data["title"] . " (NID: " . $node->id() . ")\n";
  } else {
    echo "News Article already exists: " . $data["title"] . "\n";
  }
}
'

echo -e "\n${YELLOW}[4/4] Seeding 3 Community Events...${NC}"

$DRUSH php-eval '
use Drupal\node\Entity\Node;

$events = [
  [
    "title" => "Harborview Sustainable Living Expo 2026",
    "summary" => "Discover renewable energy, electric vehicles, circular economy initiatives, and home composting at the region’s premier sustainability event.",
    "body" => "<p>Join over 6,000 community members at the Harborview Arena for the 2026 Sustainable Living Expo. Featuring 80+ exhibitors, expert keynote presentations, interactive kids workshops, and electric vehicle test-drives, this free family event showcases practical steps for climate resilience.</p><h3>Event Schedule:</h3><ul><li><strong>Date:</strong> Saturday, 14 November 2026</li><li><strong>Time:</strong> 9:30 AM – 4:30 PM</li><li><strong>Location:</strong> Harborview Arena, 110 Victoria St, North Harborview</li><li><strong>Admission:</strong> Free entry (registration required for keynote lectures)</li></ul><p>Food trucks offering local organic fare and live acoustic music will be featured throughout the day.</p>",
  ],
  [
    "title" => "Mayor’s Community Town Hall & Open Forum: coastal peninsula",
    "summary" => "Meet with City of Harborview Councillors and senior executive leadership to discuss local priorities, infrastructure, and community services.",
    "body" => "<p>The Mayor and Councillors representing the Bellarine Ward invite all residents, ratepayer associations, and local business owners to an open community forum at Ocean Grove Memorial Hall.</p><h3>Agenda:</h3><ul><li>Overview of the 2026/27 Council Budget and local capital works allocation.</li><li>Update on Bellarine coastal management, public transport links, and local road upgrades.</li><li>Dedicated 45-minute Q&A open mic session with executive directors.</li></ul><p>Light refreshments will be served following the meeting.</p>",
  ],
  [
    "title" => "Pakington Street Cultural Festival & Makers Market",
    "summary" => "Harborview’s premier multicultural festival featuring four live stages, world food markets, artisan makers stalls, and street performers.",
    "body" => "<p>Pakington Street in Harborview West comes alive with vibrant colour, music, and aromas for the annual Pakington Street Cultural Festival.</p><h3>Highlights:</h3><ul><li><strong>World Music Stage:</strong> Traditional and contemporary world music acts from regional Victoria and Melbourne.</li><li><strong>Artisan Makers Alley:</strong> Over 120 curated stalls showcasing regional ceramics, jewellery, textiles, and independent design.</li><li><strong>Global Flavours Food Village:</strong> Authentic culinary offerings from diverse migrant and multicultural community groups.</li><li><strong>Children’s Zone:</strong> Free face painting, storytelling, and Wadawurrung cultural art activities.</li></ul><p>Pakington Street will be closed to vehicle traffic between Gordon Avenue and Church Street from 6:00 AM to 8:00 PM.</p>",
  ],
];

foreach ($events as $data) {
  $query = \Drupal::entityQuery("node")
    ->condition("type", "event")
    ->condition("title", $data["title"])
    ->accessCheck(FALSE);
  $nids = $query->execute();

  if (empty($nids)) {
    $node = Node::create([
      "type" => "event",
      "title" => $data["title"],
      "status" => 1,
      "uid" => 1,
      "body" => [
        "value" => $data["body"],
        "summary" => $data["summary"],
        "format" => "basic_html",
      ],
    ]);
    $node->save();
    echo "Created Event: " . $data["title"] . " (NID: " . $node->id() . ")\n";
  } else {
    echo "Event already exists: " . $data["title"] . "\n";
  }
}
'

# Rebuild caches
$DRUSH cache:rebuild

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN}   Content Seeding Complete! Sample JSON:API Endpoints:        ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "Services:       ${CYAN}http://localhost:8080/jsonapi/node/service${NC}"
echo -e "News Articles:  ${CYAN}http://localhost:8080/jsonapi/node/news_article${NC}"
echo -e "Events:         ${CYAN}http://localhost:8080/jsonapi/node/event${NC}"
