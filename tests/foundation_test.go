package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestFoundationModule(t *testing.T) {
	t.Parallel()

	randomPrefix := fmt.Sprintf("ttest-%s", random.UniqueId())

	terraformOptions := &terraform.Options{
		TerraformDir: "./fixtures",
		Vars: map[string]interface{}{
			"prefix": randomPrefix,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	virtual_network_name := terraform.Output(t, terraformOptions, "virtual_network_name")
	assert.NotEmpty(t, virtual_network_name)
}
