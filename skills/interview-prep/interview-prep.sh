#!/bin/bash
# Interview Prep CLI Tool

set -e

CATEGORIES=("javascript" "typescript" "react" "vue" "nodejs" "python" "system-design" "database" "algorithms" "behavioral")

show_help() {
    echo "Interview Prep - AI-powered interview preparation tool"
    echo ""
    echo "Usage: interview-prep <command> [options]"
    echo ""
    echo "Commands:"
    echo "    start           Start a mock interview"
    echo "    practice        Practice specific topic"
    echo "    review          Review your answers"
    echo "    company         Company-specific preparation"
    echo "    behavioral      Behavioral questions with STAR method"
    echo "    list            List available categories"
    echo "    random          Get random questions"
    echo ""
    echo "Examples:"
    echo "    interview-prep start -c javascript -n 5"
    echo "    interview-prep practice -t system-design"
    echo "    interview-prep random"
}

list_categories() {
    echo "Available categories:"
    for cat in "${CATEGORIES[@]}"; do
        echo "  - $cat"
    done
}

get_random_questions() {
    local count=${1:-5}
    echo "Random Interview Questions (${count}):"
    echo ""
    echo "1. Explain the difference between == and === in JavaScript"
    echo "2. What is the virtual DOM and how does it work?"
    echo "3. Describe the STAR method for behavioral questions"
    echo "4. How would you design a URL shortener system?"
    echo "5. What are the pros and cons of SQL vs NoSQL databases?"
    echo "6. Explain closures in JavaScript with an example"
    echo "7. What is dependency injection and why is it useful?"
    echo "8. How does async/await work under the hood?"
    echo ""
    echo "Tip: Use 'interview-prep practice -t <topic>' to focus on specific areas"
}

start_interview() {
    local category="random"
    local count=5
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--category) category="$2"; shift 2 ;;
            -n|--count) count="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    echo "Starting Mock Interview - Category: $category"
    echo "=============================================="
    get_random_questions $count
}

practice_topic() {
    local topic=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--topic) topic="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    if [[ -z "$topic" ]]; then
        echo "Error: Please specify a topic with -t"
        exit 1
    fi
    
    echo "Practicing: $topic"
    echo "=============================================="
    
    case $topic in
        system-design)
            echo "System Design Questions:"
            echo ""
            echo "1. Design a URL shortener (like bit.ly)"
            echo "2. Design a Twitter timeline"
            echo "3. Design a chat application"
            echo "4. Design a rate limiter"
            echo "5. Design a distributed cache"
            ;;
        javascript)
            echo "JavaScript Questions:"
            echo ""
            echo "1. Explain event loop and call stack"
            echo "2. What is closure? Give an example"
            echo "3. Difference between var/let/const"
            echo "4. How does prototypal inheritance work?"
            echo "5. Explain async/await vs Promises"
            ;;
        behavioral)
            echo "Behavioral Questions (STAR Method):"
            echo ""
            echo "1. Tell me about a time you solved a difficult problem"
            echo "2. Describe a situation with a difficult team member"
            echo "3. Tell me about a time you failed and what you learned"
            echo "4. Describe a time you had to meet a tight deadline"
            echo "5. Tell me about a project you are proud of"
            echo ""
            echo "STAR Method:"
            echo "  S - Situation: Set the scene"
            echo "  T - Task: Explain your responsibility"
            echo "  A - Action: Describe what you did"
            echo "  R - Result: Share the outcome"
            ;;
        *)
            echo "Practice questions for: $topic"
            echo "1. What is $topic and when to use it?"
            echo "2. What are the advantages and disadvantages?"
            ;;
    esac
}

review_answers() {
    local file=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--file) file="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    if [[ -z "$file" ]]; then
        echo "Error: Please specify a file with -f"
        exit 1
    fi
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file"
        exit 1
    fi
    
    echo "Reviewing answers from: $file"
    echo "=============================================="
    echo "AI Feedback Tips:"
    echo "- Structure your answers clearly"
    echo "- Use STAR method for behavioral questions"
    echo "- Explain your thought process"
    echo "- Ask clarifying questions when needed"
}

company_prep() {
    local company=""
    local role="general"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --company) company="$2"; shift 2 ;;
            -r|--role) role="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    company=${company:-Random Company}
    echo "Company: $company"
    echo "Role: $role"
    echo "=============================================="
    echo "$company Interview Tips:"
    echo "1. Research recent news about the company"
    echo "2. Study the company tech stack"
    echo "3. Review common interview questions"
    echo "4. Prepare questions for the interviewer"
}

behavioral_prep() {
    local method="star"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --method) method="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    echo "Behavioral Questions - Method: $method"
    echo "=============================================="
    
    if [[ "$method" == "star" ]]; then
        echo "STAR Method Framework:"
        echo ""
        echo "S - Situation: Set the context"
        echo "T - Task: Your responsibility"
        echo "A - Action: What you did specifically"
        echo "R - Result: Quantify and share learning"
        echo ""
        echo "Common Questions:"
        echo "1. Tell me about a time you failed"
        echo "2. Describe a conflict with a teammate"
        echo "3. A time you had to meet a tight deadline"
    else
        echo "PEARL Method: Problem, Evidence, Action, Learning"
    fi
}

random_question() {
    echo "Random Question of the Day:"
    echo ""
    echo "Explain the difference between SQL and NoSQL databases."
    echo ""
    echo "Consider:"
    echo "  - Data structure (tabular vs document)"
    echo "  - Scalability (vertical vs horizontal)"
    echo "  - Use cases"
}

# Main
COMMAND=${1:-help}
shift || true

case $COMMAND in
    help|-h|--help) show_help ;;
    start) start_interview "$@" ;;
    practice) practice_topic "$@" ;;
    review) review_answers "$@" ;;
    company) company_prep "$@" ;;
    behavioral) behavioral_prep "$@" ;;
    list) list_categories ;;
    random) random_question ;;
    *) echo "Unknown command: $COMMAND"; show_help; exit 1 ;;
esac
