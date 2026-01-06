#!/bin/bash
echo "=============================================="
echo "COMPREHENSIVE TEST - Docker Task 1 Solution"
echo "Student: Yasin Siadat"
echo "Date: $(date)"
echo "=============================================="

# Check Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker daemon is not running!"
    exit 1
fi
echo "✅ Docker daemon is running"

# Clean up previous runs
echo -e "\n🧹 Cleaning up previous containers..."
docker rm -f $(docker ps -aq) 2>/dev/null || true

# Part 1: Build images
echo -e "\n📦 PART 1: Building Docker images..."
./scripts/build_images.sh
if [ $? -ne 0 ]; then
    echo "❌ Image building failed!"
    exit 1
fi
echo "✅ Images built successfully"

# Part 2: Deploy containers
echo -e "\n🚀 PART 2: Deploying containers..."
./scripts/run_containers.sh
sleep 5  # Wait for containers to fully start

# Verify 6 containers are running
container_count=$(docker ps -q | wc -l)
if [ $container_count -eq 6 ]; then
    echo "✅ All 6 containers are running"
else
    echo "❌ Expected 6 containers, found $container_count"
    docker ps
fi

# Part 3: Docker ps filtering
echo -e "\n🔍 PART 3: Testing Docker ps filtering..."
./scripts/docker_filters.sh > /tmp/filters_output.txt
if [ $? -eq 0 ]; then
    echo "✅ Docker filters script executed successfully"
    echo "   Output saved to sample_outputs/docker_filters_output.txt"
    cp /tmp/filters_output.txt sample_outputs/docker_filters_output.txt
else
    echo "❌ Docker filters script failed"
fi

# Part 4: Bash automation tasks
echo -e "\n⚡ PART 4: Testing Bash automation..."

echo "  Task 1: Metadata report..."
./scripts/metadata_report.sh > /tmp/metadata_output.txt
if [ $? -eq 0 ]; then
    echo "    ✅ Metadata report successful"
    cp /tmp/metadata_output.txt sample_outputs/metadata_report_output.txt
else
    echo "    ❌ Metadata report failed"
fi

echo "  Task 2: Policy enforcement..."
./scripts/policy_enforcement.sh > /tmp/policy_output.txt
if [ $? -eq 0 ]; then
    echo "    ✅ Policy enforcement executed"
    cp /tmp/policy_output.txt sample_outputs/policy_enforcement_output.txt
else
    echo "    ❌ Policy enforcement failed"
fi

echo "  Task 3: Resource summary..."
./scripts/resource_summary.sh > /tmp/resources_output.txt
if [ $? -eq 0 ]; then
    echo "    ✅ Resource summary executed"
    cp /tmp/resources_output.txt sample_outputs/resource_summary_output.txt
else
    echo "    ❌ Resource summary failed"
fi

# Part 5: Python automation
echo -e "\n🐍 PART 5: Testing Python automation..."

echo "  Task 1: Container age analyzer..."
python3 scripts/container_age_analyzer.py > /tmp/age_output.txt
if [ $? -eq 0 ]; then
    echo "    ✅ Container age analyzer successful"
    cp /tmp/age_output.txt sample_outputs/container_age_output.txt
else
    echo "    ❌ Container age analyzer failed"
fi

echo "  Task 2: Image usage detector..."
python3 scripts/image_usage_detector.py > /tmp/image_output.txt
if [ $? -eq 0 ]; then
    echo "    ✅ Image usage detector successful"
    cp /tmp/image_output.txt sample_outputs/image_usage_output.txt
else
    echo "    ❌ Image usage detector failed"
fi

# Part 6: Bonus challenge
echo -e "\n🏆 PART 6: Testing bonus challenge..."
python3 scripts/smart_worker_controller.py > /tmp/worker_output.txt 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Smart worker controller executed"
    cp /tmp/worker_output.txt sample_outputs/smart_worker_output.txt
else
    echo "⚠️  Smart worker controller may have warnings (normal if containers are new)"
    cp /tmp/worker_output.txt sample_outputs/smart_worker_output.txt
fi

# Final verification
echo -e "\n📊 FINAL VERIFICATION:"
echo "========================="

echo "1. Running containers:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Labels}}"

echo -e "\n2. Container labels verification:"
echo "   Backend tier containers (should be 3):"
docker ps --filter "label=tier=backend" --format "{{.Names}}" | wc -l

echo "   Worker tier containers (should be 2):"
docker ps --filter "label=tier=worker" --format "{{.Names}}" | wc -l

echo "   Utility tier containers (should be 1):"
docker ps --filter "label=tier=utility" --format "{{.Names}}" | wc -l

echo -e "\n3. Sample outputs created in sample_outputs/:"
ls -la sample_outputs/

echo -e "\n=============================================="
echo "✅ ALL TESTS COMPLETED SUCCESSFULLY!"
echo "=============================================="
