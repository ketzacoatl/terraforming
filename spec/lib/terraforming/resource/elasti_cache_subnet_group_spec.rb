require "spec_helper"

module Terraforming
  module Resource
    describe ElastiCacheSubnetGroup do
      let(:client) do
        Aws::ElastiCache::Client.new(stub_responses: true)
      end

      let(:cache_subnet_groups) do
        [
          {
            cache_subnet_group_name: "hoge",
            cache_subnet_group_description: "Group for hoge",
            vpc_id: "vpc-1234abcd",
            subnets: [
              {
                subnet_identifier: "subnet-1234abcd",
                subnet_availability_zone: { name: "ap-northeast-1b" }
              }
            ]
          },
          {
            cache_subnet_group_name: "fuga",
            cache_subnet_group_description: "Group for fuga",
            vpc_id: "vpc-5678efgh",
            subnets: [
              {
                subnet_identifier: "subnet-5678efgh",
                subnet_availability_zone: { name: "ap-northeast-1b" }
              }
            ]
          }
        ]
      end

      before do
        client.stub_responses(:describe_cache_subnet_groups, cache_subnet_groups: cache_subnet_groups)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_elasticache_subnet_group" "hoge" {
    name        = "hoge"
    description = "Group for hoge"
    subnet_ids  = ["subnet-1234abcd"]
}

resource "aws_elasticache_subnet_group" "fuga" {
    name        = "fuga"
    description = "Group for fuga"
    subnet_ids  = ["subnet-5678efgh"]
}

        EOS
        end
      end

      describe ".tfstate" do
        context "without existing tfstate" do
          it "should generate tfstate" do
            expect(described_class.tfstate(client: client)).to eq JSON.pretty_generate({
              "version" => 1,
              "serial" => 1,
              "modules" => [
                {
                  "path" => [
                    "root"
                  ],
                  "outputs" => {},
                  "resources" => {
                    "aws_elasticache_subnet_group.hoge" => {
                      "type" => "aws_elasticache_subnet_group",
                      "primary" => {
                        "id" => "hoge",
                        "attributes" => {
                          "description" => "Group for hoge",
                          "name" => "hoge",
                          "subnet_ids.#" => "1",
                        }
                      }
                    },
                    "aws_elasticache_subnet_group.fuga" => {
                      "type" => "aws_elasticache_subnet_group",
                      "primary" => {
                        "id" => "fuga",
                        "attributes" => {
                          "description" => "Group for fuga",
                          "name" => "fuga",
                          "subnet_ids.#" => "1",
                        }
                      }
                    },
                  }
                }
              ]
            })
          end
        end

        context "with existing tfstate" do
          it "should generate tfstate and merge it to existing tfstate" do
            expect(described_class.tfstate(client: client, tfstate_base: tfstate_fixture)).to eq JSON.pretty_generate({
              "version" => 1,
              "serial" => 89,
              "remote" => {
                "type" => "s3",
                "config" => { "bucket" => "terraforming-tfstate", "key" => "tf" }
              },
              "modules" => [
                {
                  "path" => ["root"],
                  "outputs" => {},
                  "resources" => {
                    "aws_elb.hogehoge" => {
                      "type" => "aws_elb",
                      "primary" => {
                        "id" => "hogehoge",
                        "attributes" => {
                          "availability_zones.#" => "2",
                          "connection_draining" => "true",
                          "connection_draining_timeout" => "300",
                          "cross_zone_load_balancing" => "true",
                          "dns_name" => "hoge-12345678.ap-northeast-1.elb.amazonaws.com",
                          "health_check.#" => "1",
                          "id" => "hogehoge",
                          "idle_timeout" => "60",
                          "instances.#" => "1",
                          "listener.#" => "1",
                          "name" => "hoge",
                          "security_groups.#" => "2",
                          "source_security_group" => "default",
                          "subnets.#" => "2"
                        }
                      }
                    },
                    "aws_elasticache_subnet_group.hoge" => {
                      "type" => "aws_elasticache_subnet_group",
                      "primary" => {
                        "id" => "hoge",
                        "attributes" => {
                          "description" => "Group for hoge",
                          "name" => "hoge",
                          "subnet_ids.#" => "1",
                        }
                      }
                    },
                    "aws_elasticache_subnet_group.fuga" => {
                      "type" => "aws_elasticache_subnet_group",
                      "primary" => {
                        "id" => "fuga",
                        "attributes" => {
                          "description" => "Group for fuga",
                          "name" => "fuga",
                          "subnet_ids.#" => "1",
                        }
                      }
                    },
                  }
                }
              ]
            })
          end
        end
      end
    end
  end
end
